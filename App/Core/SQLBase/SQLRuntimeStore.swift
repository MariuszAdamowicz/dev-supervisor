import Foundation
import SQLite3

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct SQLRuntimeStoreStats: Equatable {
    let entityCount: Int
    let coreOpCount: Int
    let controlCount: Int
    let relationCount: Int
    let processEventCount: Int
    let gateDecisionCount: Int
    let evidenceCount: Int

    var opCount: Int {
        coreOpCount
    }
}

struct SQLRuntimeStore {
    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func databaseURL(projectRoot: URL) -> URL {
        projectRoot.appendingPathComponent("State/supervisor.sqlite3")
    }

    func latestSnapshot(for opID: String, projectRoot: URL) throws -> RuntimeOpSnapshot? {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            let sql = """
            SELECT snapshot_json
            FROM op_versions
            WHERE op_id = ?
            ORDER BY version DESC
            LIMIT 1
            """
            return try queryOptionalSnapshot(db: db, sql: sql, values: [.text(opID)])
        }
    }

    func latestVersion(for opID: String, projectRoot: URL) throws -> Int {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            try scalarInt(
                db: db,
                sql: "SELECT COALESCE(MAX(version), 0) FROM op_versions WHERE op_id = ?",
                values: [.text(opID)]
            )
        }
    }

    func upsertSnapshot(_ snapshot: RuntimeOpSnapshot, projectRoot: URL) throws {
        try withDatabase(projectRoot: projectRoot) { db in
            try upsertSnapshot(snapshot, db: db)
        }
    }

    func appendProcessEvent(_ event: RuntimeProcessEvent, projectRoot: URL) throws {
        try withDatabase(projectRoot: projectRoot) { db in
            try insertProcessEvent(event, db: db)
        }
    }

    func appendGateDecision(_ gate: RuntimeGateDecision, projectRoot: URL) throws {
        try withDatabase(projectRoot: projectRoot) { db in
            try insertGateDecision(gate, db: db)
        }
    }

    func appendEvidence(_ evidence: RuntimeEvidenceRecord, projectRoot: URL) throws {
        try withDatabase(projectRoot: projectRoot) { db in
            try insertEvidence(evidence, db: db)
        }
    }

    func nextSequentialOpID(prefix: String, projectRoot: URL) throws -> String {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            let sql = "SELECT op_id FROM op_instances WHERE op_id LIKE ? ORDER BY op_id ASC"
            let pattern = "\(prefix).%"
            let opIDs = try queryTextColumn(db: db, sql: sql, values: [.text(pattern)])
            let next = (opIDs.compactMap { opID -> Int? in
                guard opID.hasPrefix("\(prefix).") else {
                    return nil
                }
                return Int(opID.replacingOccurrences(of: "\(prefix).", with: ""))
            }.max() ?? 0) + 1
            return "\(prefix).\(String(format: "%04d", next))"
        }
    }

    func nextProcessEventID(projectRoot: URL) throws -> String {
        let count = try countRows(in: "process_events", projectRoot: projectRoot)
        return String(format: "evt_%04d", count + 1)
    }

    func nextGateDecisionID(projectRoot: URL) throws -> String {
        let count = try countRows(in: "gate_decisions", projectRoot: projectRoot)
        return String(format: "gate_%04d", count + 1)
    }

    func nextEvidenceID(projectRoot: URL) throws -> String {
        let count = try countRows(in: "evidence_records", projectRoot: projectRoot)
        return String(format: "evidence_%04d", count + 1)
    }

    func allEntitySummaries(projectRoot: URL) throws -> [PlaybookDerivedOPSummary] {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            let sql = """
            SELECT op_id, op_type, current_state
            FROM op_instances
            ORDER BY op_id ASC
            """
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
                throw sqlError(db, message: "Failed to prepare op summary query.")
            }
            defer { sqlite3_finalize(statement) }

            var summaries: [PlaybookDerivedOPSummary] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                summaries.append(
                    PlaybookDerivedOPSummary(
                        opID: text(at: 0, in: statement) ?? "",
                        opType: text(at: 1, in: statement) ?? "",
                        state: text(at: 2, in: statement) ?? "",
                        category: playbookRuntimeEntityCategory(for: text(at: 1, in: statement) ?? "")
                    )
                )
            }
            return summaries
        }
    }

    func processEventCount(projectRoot: URL) throws -> Int {
        try countRows(in: "process_events", projectRoot: projectRoot)
    }

    func gateDecisionCount(projectRoot: URL) throws -> Int {
        try countRows(in: "gate_decisions", projectRoot: projectRoot)
    }

    func evidenceCount(projectRoot: URL) throws -> Int {
        try countRows(in: "evidence_records", projectRoot: projectRoot)
    }

    func lastEvidenceClass(projectRoot: URL) throws -> String? {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            try scalarOptionalText(
                db: db,
                sql: "SELECT evidence_class FROM evidence_records ORDER BY evidence_id DESC LIMIT 1",
                values: []
            )
        }
    }

    func opIndexEntries(projectRoot: URL) throws -> [RuntimeOpIndexEntry] {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            let sql = """
            SELECT
              i.op_id,
              i.op_type,
              i.current_state,
              COALESCE((
                SELECT r.target_op_id
                FROM op_relations r
                WHERE r.source_op_id = i.op_id
                  AND r.rel = 'parent'
                  AND r.active = 1
                LIMIT 1
              ), ''),
              i.terminal,
              COALESCE(i.last_event_id, '')
            FROM op_instances i
            ORDER BY i.op_id ASC
            """
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
                throw sqlError(db, message: "Failed to prepare op index query.")
            }
            defer { sqlite3_finalize(statement) }

            var entries: [RuntimeOpIndexEntry] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                let parentID = text(at: 3, in: statement)
                entries.append(
                    RuntimeOpIndexEntry(
                        opID: text(at: 0, in: statement) ?? "",
                        opType: text(at: 1, in: statement) ?? "",
                        state: text(at: 2, in: statement) ?? "",
                        parentID: parentID?.isEmpty == true ? nil : parentID,
                        terminal: int(at: 4, in: statement) == 1,
                        lastEventID: text(at: 5, in: statement) ?? ""
                    )
                )
            }
            return entries
        }
    }

    func stats(projectRoot: URL) throws -> SQLRuntimeStoreStats {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            let opTypes = try queryTextColumn(db: db, sql: "SELECT op_type FROM op_instances", values: [])
            let coreOpCount = opTypes.filter { playbookRuntimeEntityCategory(for: $0) == .coreOP }.count
            let entityCount = opTypes.count

            return try SQLRuntimeStoreStats(
                entityCount: entityCount,
                coreOpCount: coreOpCount,
                controlCount: entityCount - coreOpCount,
                relationCount: scalarInt(db: db, sql: "SELECT COUNT(*) FROM op_relations", values: []),
                processEventCount: scalarInt(db: db, sql: "SELECT COUNT(*) FROM process_events", values: []),
                gateDecisionCount: scalarInt(db: db, sql: "SELECT COUNT(*) FROM gate_decisions", values: []),
                evidenceCount: scalarInt(db: db, sql: "SELECT COUNT(*) FROM evidence_records", values: [])
            )
        }
    }
}

private extension SQLRuntimeStore {
    enum SQLiteValue {
        case text(String)
        case int(Int)
        case null
    }

    func withDatabase<T>(
        projectRoot: URL,
        importExisting: Bool = false,
        _ body: (OpaquePointer) throws -> T
    ) throws -> T {
        let databaseURL = databaseURL(projectRoot: projectRoot)
        try fileManager.createDirectory(at: databaseURL.deletingLastPathComponent(), withIntermediateDirectories: true)

        var database: OpaquePointer?
        guard sqlite3_open(databaseURL.path, &database) == SQLITE_OK, let database else {
            throw sqlError(database, message: "Failed to open SQLBase runtime store.")
        }
        defer { sqlite3_close(database) }

        try migrate(database)
        if importExisting {
            try importFileRuntimeIfNeeded(projectRoot: projectRoot, db: database)
        }

        return try body(database)
    }

    func migrate(_ db: OpaquePointer) throws {
        let statements = [
            """
            CREATE TABLE IF NOT EXISTS runtime_metadata (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
            """,
            """
            INSERT OR IGNORE INTO runtime_metadata (key, value)
            VALUES ('schema_version', 'sqlbase-runtime/v1')
            """,
            """
            CREATE TABLE IF NOT EXISTS op_instances (
              op_id TEXT PRIMARY KEY,
              op_type TEXT NOT NULL,
              current_state TEXT NOT NULL,
              owner TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              current_version INTEGER NOT NULL,
              terminal INTEGER NOT NULL,
              deprecated INTEGER NOT NULL,
              replacement_op_id TEXT,
              last_event_id TEXT,
              payload_json TEXT,
              tags_json TEXT
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS op_versions (
              op_id TEXT NOT NULL,
              version INTEGER NOT NULL,
              snapshot_json TEXT NOT NULL,
              created_at TEXT NOT NULL,
              PRIMARY KEY (op_id, version)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS op_relations (
              source_op_id TEXT NOT NULL,
              rel TEXT NOT NULL,
              target_op_id TEXT NOT NULL,
              active INTEGER NOT NULL,
              updated_at TEXT NOT NULL,
              PRIMARY KEY (source_op_id, rel, target_op_id)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS process_events (
              event_id TEXT PRIMARY KEY,
              op_id TEXT NOT NULL,
              op_type TEXT,
              event_type TEXT NOT NULL,
              payload_hash TEXT NOT NULL,
              actor TEXT NOT NULL,
              ts TEXT NOT NULL,
              idempotency_key TEXT NOT NULL UNIQUE,
              from_state TEXT,
              to_state TEXT,
              gate_decision_id TEXT,
              record_json TEXT NOT NULL
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS gate_decisions (
              decision_id TEXT PRIMARY KEY,
              op_id TEXT NOT NULL,
              gate_type TEXT NOT NULL,
              decision TEXT NOT NULL,
              reason TEXT NOT NULL,
              actor TEXT NOT NULL,
              ts TEXT NOT NULL,
              idempotency_key TEXT NOT NULL UNIQUE,
              record_json TEXT NOT NULL
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS evidence_records (
              evidence_id TEXT PRIMARY KEY,
              evidence_class TEXT NOT NULL,
              source_ref TEXT NOT NULL,
              executor_ref TEXT NOT NULL,
              actor_or_system TEXT NOT NULL,
              subject_hash TEXT NOT NULL,
              started_at TEXT NOT NULL,
              finished_at TEXT NOT NULL,
              environment TEXT NOT NULL,
              replayable_input_ref TEXT NOT NULL,
              attestation_ref TEXT,
              idempotency_key TEXT NOT NULL UNIQUE,
              record_json TEXT NOT NULL
            )
            """,
        ]

        for statement in statements {
            try execute(statement, db: db)
        }
    }

    func importFileRuntimeIfNeeded(projectRoot: URL, db: OpaquePointer) throws {
        guard try scalarInt(db: db, sql: "SELECT COUNT(*) FROM op_instances", values: []) == 0 else {
            return
        }

        let opsRoot = projectRoot.appendingPathComponent(".ai/runtime/v1/ops")
        let opDirectories = (try? fileManager.contentsOfDirectory(
            at: opsRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        guard !opDirectories.isEmpty else {
            return
        }

        try execute("BEGIN IMMEDIATE TRANSACTION", db: db)
        do {
            let decoder = JSONDecoder()

            for opDirectory in opDirectories.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                let versionsURL = opDirectory.appendingPathComponent("versions")
                let versionFiles = (try? fileManager.contentsOfDirectory(
                    at: versionsURL,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )) ?? []
                for versionFile in versionFiles
                    .filter({ $0.pathExtension == "json" })
                    .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
                {
                    let data = try Data(contentsOf: versionFile)
                    let snapshot = try decoder.decode(RuntimeOpSnapshot.self, from: data)
                    try upsertSnapshot(snapshot, db: db)
                }
            }

            let processEventsURL = projectRoot.appendingPathComponent(".ai/runtime/v1/process-events.ndjson")
            for event in try loadNDJSON(RuntimeProcessEvent.self, from: processEventsURL) {
                try insertProcessEvent(event, db: db)
            }

            let gateDecisionsURL = projectRoot.appendingPathComponent(".ai/runtime/v1/gate-decisions.ndjson")
            for gate in try loadNDJSON(RuntimeGateDecision.self, from: gateDecisionsURL) {
                try insertGateDecision(gate, db: db)
            }

            let evidenceURL = projectRoot.appendingPathComponent(".ai/runtime/v1/evidence.ndjson")
            for evidence in try loadNDJSON(RuntimeEvidenceRecord.self, from: evidenceURL) {
                try insertEvidence(evidence, db: db)
            }

            try execute(
                "INSERT OR REPLACE INTO runtime_metadata (key, value) VALUES ('file_ai_imported_at', ?)",
                db: db,
                values: [.text(ISO8601DateFormatter().string(from: Date()))]
            )
            try execute("COMMIT", db: db)
        } catch {
            try? execute("ROLLBACK", db: db)
            throw error
        }
    }

    func upsertSnapshot(_ snapshot: RuntimeOpSnapshot, db: OpaquePointer) throws {
        let snapshotJSON = try encode(snapshot)
        let payloadJSON = try encodeOptional(snapshot.payload)
        let tagsJSON = try encode(snapshot.tags)
        let terminal = snapshot.state == "archived"
            || snapshot.state == "cancelled"
            || snapshot.state == "closed"
            || snapshot.state == "converted"
            || snapshot.state == "deprecated"
            || snapshot.state == "done"
            || snapshot.state == "dropped"
            || snapshot.state == "published"
            || snapshot.state == "revoked"

        try execute(
            """
            INSERT OR REPLACE INTO op_instances (
              op_id, op_type, current_state, owner, created_at, updated_at,
              current_version, terminal, deprecated, replacement_op_id,
              last_event_id, payload_json, tags_json
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            db: db,
            values: [
                .text(snapshot.opID),
                .text(snapshot.opType),
                .text(snapshot.state),
                .text(snapshot.owner),
                .text(snapshot.createdAt),
                .text(snapshot.updatedAt),
                .int(snapshot.opVersion),
                .int(terminal ? 1 : 0),
                .int(snapshot.state == "deprecated" ? 1 : 0),
                .null,
                .text(snapshot.lastEventID),
                payloadJSON.map(SQLiteValue.text) ?? .null,
                .text(tagsJSON),
            ]
        )

        try execute(
            """
            INSERT OR REPLACE INTO op_versions (op_id, version, snapshot_json, created_at)
            VALUES (?, ?, ?, ?)
            """,
            db: db,
            values: [
                .text(snapshot.opID),
                .int(snapshot.opVersion),
                .text(snapshotJSON),
                .text(snapshot.updatedAt),
            ]
        )

        try execute(
            "DELETE FROM op_relations WHERE source_op_id = ?",
            db: db,
            values: [.text(snapshot.opID)]
        )

        for link in snapshot.links {
            try execute(
                """
                INSERT OR REPLACE INTO op_relations (source_op_id, rel, target_op_id, active, updated_at)
                VALUES (?, ?, ?, 1, ?)
                """,
                db: db,
                values: [
                    .text(snapshot.opID),
                    .text(link.rel),
                    .text(link.target),
                    .text(snapshot.updatedAt),
                ]
            )
        }
    }

    func insertProcessEvent(_ event: RuntimeProcessEvent, db: OpaquePointer) throws {
        try execute(
            """
            INSERT OR IGNORE INTO process_events (
              event_id, op_id, op_type, event_type, payload_hash, actor,
              ts, idempotency_key, from_state, to_state, gate_decision_id, record_json
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            db: db,
            values: [
                .text(event.eventID),
                .text(event.opID),
                event.opType.map(SQLiteValue.text) ?? .null,
                .text(event.eventType),
                .text(event.payloadHash),
                .text(event.actor),
                .text(event.ts),
                .text(event.idempotencyKey),
                event.fromState.map(SQLiteValue.text) ?? .null,
                event.toState.map(SQLiteValue.text) ?? .null,
                event.gateDecisionID.map(SQLiteValue.text) ?? .null,
                .text(encode(event)),
            ]
        )
    }

    func insertGateDecision(_ gate: RuntimeGateDecision, db: OpaquePointer) throws {
        try execute(
            """
            INSERT OR IGNORE INTO gate_decisions (
              decision_id, op_id, gate_type, decision, reason, actor,
              ts, idempotency_key, record_json
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            db: db,
            values: [
                .text(gate.decisionID),
                .text(gate.opID),
                .text(gate.gateType),
                .text(gate.decision),
                .text(gate.reason),
                .text(gate.actor),
                .text(gate.ts),
                .text(gate.idempotencyKey),
                .text(encode(gate)),
            ]
        )
    }

    func insertEvidence(_ evidence: RuntimeEvidenceRecord, db: OpaquePointer) throws {
        try execute(
            """
            INSERT OR IGNORE INTO evidence_records (
              evidence_id, evidence_class, source_ref, executor_ref, actor_or_system,
              subject_hash, started_at, finished_at, environment, replayable_input_ref,
              attestation_ref, idempotency_key, record_json
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            db: db,
            values: [
                .text(evidence.evidenceID),
                .text(evidence.evidenceClass),
                .text(evidence.sourceRef),
                .text(evidence.executorRef),
                .text(evidence.actorOrSystem),
                .text(evidence.subjectHash),
                .text(evidence.startedAt),
                .text(evidence.finishedAt),
                .text(evidence.environment),
                .text(evidence.replayableInputRef),
                evidence.attestationRef.map(SQLiteValue.text) ?? .null,
                .text(evidence.idempotencyKey),
                .text(encode(evidence)),
            ]
        )
    }

    func countRows(in table: String, projectRoot: URL) throws -> Int {
        try withDatabase(projectRoot: projectRoot, importExisting: true) { db in
            try scalarInt(db: db, sql: "SELECT COUNT(*) FROM \(table)", values: [])
        }
    }

    func loadNDJSON<Record: Decodable>(_ type: Record.Type, from url: URL) throws -> [Record] {
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }

        let decoder = JSONDecoder()
        let text = try String(contentsOf: url, encoding: .utf8)
        return try text
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { !$0.isEmpty }
            .map { line in
                guard let data = line.data(using: .utf8) else {
                    throw RuntimeError(message: "Failed to read NDJSON record from \(url.path).")
                }
                return try decoder.decode(type, from: data)
            }
    }

    func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        return String(decoding: data, as: UTF8.self)
    }

    func encodeOptional<T: Encodable>(_ value: T?) throws -> String? {
        guard let value else {
            return nil
        }
        return try encode(value)
    }

    func scalarInt(
        db: OpaquePointer,
        sql: String,
        values: [SQLiteValue]
    ) throws -> Int {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError(db, message: "Failed to prepare scalar int query.")
        }
        defer { sqlite3_finalize(statement) }
        try bind(values, to: statement)

        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw sqlError(db, message: "Scalar int query returned no row.")
        }
        return Int(sqlite3_column_int64(statement, 0))
    }

    func scalarOptionalText(
        db: OpaquePointer,
        sql: String,
        values: [SQLiteValue]
    ) throws -> String? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError(db, message: "Failed to prepare scalar text query.")
        }
        defer { sqlite3_finalize(statement) }
        try bind(values, to: statement)

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return nil
        }
        return text(at: 0, in: statement)
    }

    func queryTextColumn(
        db: OpaquePointer,
        sql: String,
        values: [SQLiteValue]
    ) throws -> [String] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError(db, message: "Failed to prepare text column query.")
        }
        defer { sqlite3_finalize(statement) }
        try bind(values, to: statement)

        var results: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let value = text(at: 0, in: statement) {
                results.append(value)
            }
        }
        return results
    }

    func queryOptionalSnapshot(
        db: OpaquePointer,
        sql: String,
        values: [SQLiteValue]
    ) throws -> RuntimeOpSnapshot? {
        guard let json = try scalarOptionalText(db: db, sql: sql, values: values) else {
            return nil
        }
        return try JSONDecoder().decode(RuntimeOpSnapshot.self, from: Data(json.utf8))
    }

    func execute(_ sql: String, db: OpaquePointer, values: [SQLiteValue] = []) throws {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError(db, message: "Failed to prepare SQL statement.")
        }
        defer { sqlite3_finalize(statement) }
        try bind(values, to: statement)

        let stepResult = sqlite3_step(statement)
        guard stepResult == SQLITE_DONE || stepResult == SQLITE_ROW else {
            throw sqlError(db, message: "SQL statement execution failed.")
        }
    }

    func bind(_ values: [SQLiteValue], to statement: OpaquePointer?) throws {
        for (index, value) in values.enumerated() {
            let position = Int32(index + 1)
            let result: Int32

            switch value {
            case let .text(text):
                result = sqlite3_bind_text(statement, position, text, -1, sqliteTransient)
            case let .int(number):
                result = sqlite3_bind_int64(statement, position, sqlite3_int64(number))
            case .null:
                result = sqlite3_bind_null(statement, position)
            }

            guard result == SQLITE_OK else {
                throw RuntimeError(message: "Failed to bind SQL parameter at index \(index).")
            }
        }
    }

    func text(at index: Int32, in statement: OpaquePointer?) -> String? {
        guard let pointer = sqlite3_column_text(statement, index) else {
            return nil
        }
        return String(cString: pointer)
    }

    func int(at index: Int32, in statement: OpaquePointer?) -> Int {
        Int(sqlite3_column_int64(statement, index))
    }

    func sqlError(_ db: OpaquePointer?, message: String) -> RuntimeError {
        let detail = db.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
        return RuntimeError(message: "\(message) SQLite error: \(detail)")
    }
}
