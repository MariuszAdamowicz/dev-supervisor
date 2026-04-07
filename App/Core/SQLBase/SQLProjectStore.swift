import Foundation
import SQLite3

private let projectSQLiteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct SQLProjectStore {
    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func databaseURL(projectRoot: URL) -> URL {
        projectRoot.appendingPathComponent("State/supervisor.sqlite3")
    }

    func ensureDatabase(projectRoot: URL) throws {
        try withDatabase(projectRoot: projectRoot) { _ in }
    }

    func storeArtifactFile(at fileURL: URL, projectRoot: URL) throws -> String {
        let relativePath = try relativePath(for: fileURL, projectRoot: projectRoot)
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        try upsertArtifact(relativePath: relativePath, content: content, projectRoot: projectRoot)
        return artifactReference(relativePath: relativePath, projectRoot: projectRoot)
    }

    func upsertArtifact(relativePath: String, content: String, projectRoot: URL) throws {
        try withDatabase(projectRoot: projectRoot) { database in
            try execute(
                """
                INSERT INTO project_artifacts (artifact_key, content, updated_at)
                VALUES (?, ?, ?)
                ON CONFLICT(artifact_key) DO UPDATE SET
                    content = excluded.content,
                    updated_at = excluded.updated_at
                """,
                database: database,
                values: [
                    .text(relativePath),
                    .text(content),
                    .text(timestamp()),
                ]
            )
        }
    }

    func artifactContent(relativePath: String, projectRoot: URL) throws -> String? {
        try withDatabase(projectRoot: projectRoot) { database in
            try scalarOptionalText(
                """
                SELECT content
                FROM project_artifacts
                WHERE artifact_key = ?
                """,
                database: database,
                values: [.text(relativePath)]
            )
        }
    }

    func artifactKeys(projectRoot: URL) throws -> [String] {
        try withDatabase(projectRoot: projectRoot) { database in
            try queryTextColumn(
                """
                SELECT artifact_key
                FROM project_artifacts
                ORDER BY artifact_key ASC
                """,
                database: database
            )
        }
    }

    func artifactCount(projectRoot: URL) throws -> Int {
        try withDatabase(projectRoot: projectRoot) { database in
            try scalarInt("SELECT COUNT(*) FROM project_artifacts", database: database)
        }
    }

    func materializeArtifact(relativePath: String, projectRoot: URL) throws -> String {
        guard let content = try artifactContent(relativePath: relativePath, projectRoot: projectRoot) else {
            throw RuntimeError(message: "Missing SQL artifact: \(relativePath)")
        }

        let destinationURL = projectRoot.appendingPathComponent(relativePath)
        try fileManager.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try content.write(to: destinationURL, atomically: true, encoding: .utf8)
        return destinationURL.path
    }

    func persistGatePrompt(_ request: GatePromptPersistenceRequest, projectRoot: URL, createdAt: Date = Date()) throws -> String {
        let operationSlug = slugify(request.operation)
        let timestampValue = Self.timestampFormatter.string(from: createdAt)
        let ideaID = request.ideaID?.rawValue ?? "no-idea"
        let projectID = request.projectID?.rawValue ?? "no-project"
        let filename = "\(timestampValue)_\(projectID)_\(ideaID).md"
        let logicalPath = "\(databaseURL(projectRoot: projectRoot).path)#gates/\(operationSlug)/\(filename)"
        let payload = gatePromptPayload(
            operation: request.operation,
            projectID: projectID,
            ideaID: ideaID,
            storage: request.storageProfile.rawValue,
            promptText: request.promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        try withDatabase(projectRoot: projectRoot) { database in
            let promptID = try nextGatePromptID(database: database)
            try execute(
                """
                INSERT INTO gate_prompt_records (
                    prompt_id, operation_slug, project_id, idea_id, logical_path, payload_markdown, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                database: database,
                values: [
                    .text(promptID),
                    .text(operationSlug),
                    request.projectID.map { .text($0.rawValue) } ?? .null,
                    request.ideaID.map { .text($0.rawValue) } ?? .null,
                    .text(logicalPath),
                    .text(payload),
                    .text(timestampValue),
                ]
            )
        }

        return logicalPath
    }

    func gatePromptCount(projectRoot: URL) throws -> Int {
        try withDatabase(projectRoot: projectRoot) { database in
            try scalarInt("SELECT COUNT(*) FROM gate_prompt_records", database: database)
        }
    }

    func gatePromptPayload(logicalPath: String, projectRoot: URL) throws -> String? {
        try withDatabase(projectRoot: projectRoot) { database in
            try scalarOptionalText(
                """
                SELECT payload_markdown
                FROM gate_prompt_records
                WHERE logical_path = ?
                """,
                database: database,
                values: [.text(logicalPath)]
            )
        }
    }

    func artifactReference(relativePath: String, projectRoot: URL) -> String {
        "\(databaseURL(projectRoot: projectRoot).path)#artifacts/\(relativePath)"
    }
}

private extension SQLProjectStore {
    enum SQLiteValue {
        case text(String)
        case int(Int)
        case null
    }

    private static let legacyArtifactMappings: [(artifactKey: String, legacyRelativePath: String)] = [
        (".ai/prd/overview.md", "State/sqlbase/prd/overview.md"),
        (".ai/prd/constraints.md", "State/sqlbase/prd/constraints.md"),
        (".ai/prd/glossary.md", "State/sqlbase/prd/glossary.md"),
        (".ai/ideas.md", "State/sqlbase/ideas.md"),
        (".ai/project-profile.json", "State/sqlbase/project-profile.json"),
    ]

    static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()

    func withDatabase<T>(projectRoot: URL, _ body: (OpaquePointer) throws -> T) throws -> T {
        try fileManager.createDirectory(at: databaseURL(projectRoot: projectRoot).deletingLastPathComponent(), withIntermediateDirectories: true)

        var database: OpaquePointer?
        guard sqlite3_open(databaseURL(projectRoot: projectRoot).path, &database) == SQLITE_OK, let database else {
            defer { if database != nil { sqlite3_close(database) } }
            throw sqlError("Failed to open SQL project database", database: database)
        }
        defer { sqlite3_close(database) }

        try migrate(database: database)
        try importLegacyArtifactsIfNeeded(projectRoot: projectRoot, database: database)
        try importLegacyGatePromptsIfNeeded(projectRoot: projectRoot, database: database)

        return try body(database)
    }

    func migrate(database: OpaquePointer) throws {
        try execute("PRAGMA journal_mode = WAL", database: database)
        try execute(
            """
            CREATE TABLE IF NOT EXISTS project_artifacts (
                artifact_key TEXT PRIMARY KEY,
                content TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
            """,
            database: database
        )
        try execute(
            """
            CREATE TABLE IF NOT EXISTS gate_prompt_records (
                prompt_id TEXT PRIMARY KEY,
                operation_slug TEXT NOT NULL,
                project_id TEXT,
                idea_id TEXT,
                logical_path TEXT NOT NULL UNIQUE,
                payload_markdown TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """,
            database: database
        )
    }

    func importLegacyArtifactsIfNeeded(projectRoot: URL, database: OpaquePointer) throws {
        let count = try scalarInt("SELECT COUNT(*) FROM project_artifacts", database: database)
        guard count == 0 else {
            return
        }

        for mapping in Self.legacyArtifactMappings {
            let sourceURL = projectRoot.appendingPathComponent(mapping.legacyRelativePath)
            guard fileManager.fileExists(atPath: sourceURL.path) else {
                continue
            }

            let content = try String(contentsOf: sourceURL, encoding: .utf8)
            try execute(
                """
                INSERT INTO project_artifacts (artifact_key, content, updated_at)
                VALUES (?, ?, ?)
                ON CONFLICT(artifact_key) DO UPDATE SET
                    content = excluded.content,
                    updated_at = excluded.updated_at
                """,
                database: database,
                values: [
                    .text(mapping.artifactKey),
                    .text(content),
                    .text(timestamp()),
                ]
            )
        }
    }

    func importLegacyGatePromptsIfNeeded(projectRoot: URL, database: OpaquePointer) throws {
        let count = try scalarInt("SELECT COUNT(*) FROM gate_prompt_records", database: database)
        guard count == 0 else {
            return
        }

        let gatesRoot = projectRoot.appendingPathComponent("State/gates")
        guard fileManager.fileExists(atPath: gatesRoot.path) else {
            return
        }

        let enumerator = fileManager.enumerator(
            at: gatesRoot,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        var index = 1
        while let fileURL = enumerator?.nextObject() as? URL {
            let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true, fileURL.pathExtension == "md" else {
                continue
            }

            let operationSlug = fileURL.deletingLastPathComponent().lastPathComponent
            let createdAt = Self.timestampFormatter.string(from: fileModificationDate(fileURL))
            let filename = fileURL.lastPathComponent
            let logicalPath = "\(databaseURL(projectRoot: projectRoot).path)#gates/\(operationSlug)/\(filename)"
            let payload = try String(contentsOf: fileURL, encoding: .utf8)
            let metadata = parseLegacyGatePayload(payload)

            try execute(
                """
                INSERT INTO gate_prompt_records (
                    prompt_id, operation_slug, project_id, idea_id, logical_path, payload_markdown, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                database: database,
                values: [
                    .text(String(format: "gateprompt_%04d", index)),
                    .text(operationSlug),
                    metadata.projectID.map(SQLiteValue.text) ?? .null,
                    metadata.ideaID.map(SQLiteValue.text) ?? .null,
                    .text(logicalPath),
                    .text(payload),
                    .text(createdAt),
                ]
            )

            index += 1
        }
    }

    func parseLegacyGatePayload(_ payload: String) -> (projectID: String?, ideaID: String?) {
        let sections = payload.components(separatedBy: "\n---\n")
        guard let metadataBlock = sections.first else {
            return (nil, nil)
        }

        var projectID: String?
        var ideaID: String?
        for line in metadataBlock.split(separator: "\n") {
            let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else {
                continue
            }

            switch parts[0] {
            case "project_id":
                projectID = parts[1] == "no-project" ? nil : parts[1]
            case "idea_id":
                ideaID = parts[1] == "no-idea" ? nil : parts[1]
            default:
                continue
            }
        }

        return (projectID, ideaID)
    }

    func relativePath(for fileURL: URL, projectRoot: URL) throws -> String {
        let projectPath = projectRoot.standardizedFileURL.path
        let filePath = fileURL.standardizedFileURL.path
        guard filePath.hasPrefix(projectPath + "/") else {
            throw RuntimeError(message: "Cannot derive relative path for SQL project artifact.")
        }
        return String(filePath.dropFirst(projectPath.count + 1))
    }

    func fileModificationDate(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
    }

    func nextGatePromptID(database: OpaquePointer) throws -> String {
        let count = try scalarInt("SELECT COUNT(*) FROM gate_prompt_records", database: database)
        return String(format: "gateprompt_%04d", count + 1)
    }

    func gatePromptPayload(
        operation: String,
        projectID: String,
        ideaID: String,
        storage: String,
        promptText: String
    ) -> String {
        """
        operation: \(operation)
        project_id: \(projectID)
        idea_id: \(ideaID)
        storage: \(storage)
        ---
        \(promptText)
        """
    }

    func slugify(_ value: String) -> String {
        let lowered = value.lowercased()
        let replaced = lowered.replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
        return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    func execute(_ sql: String, database: OpaquePointer, values: [SQLiteValue] = []) throws {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to prepare SQL statement", database: database)
        }
        defer { sqlite3_finalize(statement) }

        try bind(values, to: statement)

        let result = sqlite3_step(statement)
        guard result == SQLITE_DONE || result == SQLITE_ROW else {
            throw sqlError("Failed to execute SQL statement", database: database)
        }
    }

    func bind(_ values: [SQLiteValue], to statement: OpaquePointer?) throws {
        for (offset, value) in values.enumerated() {
            let index = Int32(offset + 1)
            switch value {
            case let .text(text):
                sqlite3_bind_text(statement, index, text, -1, projectSQLiteTransient)
            case let .int(number):
                sqlite3_bind_int(statement, index, Int32(number))
            case .null:
                sqlite3_bind_null(statement, index)
            }
        }
    }

    func scalarInt(_ sql: String, database: OpaquePointer, values: [SQLiteValue] = []) throws -> Int {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query integer scalar", database: database)
        }
        defer { sqlite3_finalize(statement) }

        try bind(values, to: statement)

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return 0
        }
        return Int(sqlite3_column_int(statement, 0))
    }

    func scalarOptionalText(_ sql: String, database: OpaquePointer, values: [SQLiteValue] = []) throws -> String? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query text scalar", database: database)
        }
        defer { sqlite3_finalize(statement) }

        try bind(values, to: statement)

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return nil
        }
        return text(at: 0, in: statement)
    }

    func queryTextColumn(_ sql: String, database: OpaquePointer, values: [SQLiteValue] = []) throws -> [String] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query text column", database: database)
        }
        defer { sqlite3_finalize(statement) }

        try bind(values, to: statement)

        var rows: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let value = text(at: 0, in: statement) {
                rows.append(value)
            }
        }
        return rows
    }

    func text(at index: Int32, in statement: OpaquePointer?) -> String? {
        guard let raw = sqlite3_column_text(statement, index) else {
            return nil
        }
        return String(cString: raw)
    }

    func timestamp() -> String {
        ISO8601DateFormatter().string(from: Date())
    }

    func sqlError(_ message: String, database: OpaquePointer?) -> RuntimeError {
        let detail = database.flatMap { sqlite3_errmsg($0) }.map { String(cString: $0) } ?? "unknown"
        return RuntimeError(message: "\(message) SQLite error: \(detail)")
    }
}
