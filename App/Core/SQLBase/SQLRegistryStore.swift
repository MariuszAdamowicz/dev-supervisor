import Foundation
import SQLite3

private let registrySQLiteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct SQLRegistryStore {
    let fileManager: FileManager = .default

    func databaseURL(storageRoot: URL) -> URL {
        storageRoot.appendingPathComponent("registry-sqlbase.sqlite3")
    }

    func loadProjectSnapshot(storageRoot: URL) throws -> ProjectRegistryStateSnapshot? {
        try withDatabase(storageRoot: storageRoot) { db in
            try importLegacyProjectSnapshotIfNeeded(storageRoot: storageRoot, db: db)

            let projects = try queryProjectRecords(db: db)
            let selectedProjectID = try scalarOptionalText(
                "SELECT value FROM registry_metadata WHERE key = 'project_active_id'",
                db: db
            )
            let nextProjectNumber = try scalarInt(
                "SELECT COALESCE(CAST(value AS INTEGER), 1) FROM registry_metadata WHERE key = 'project_next_number'",
                db: db,
                fallback: 1
            )
            let scopedData = try queryProjectScopedData(db: db)
            let pathAvailability = try queryPathAvailability(db: db)

            guard !projects.isEmpty || selectedProjectID != nil || nextProjectNumber != 1 else {
                return nil
            }

            return ProjectRegistryStateSnapshot(
                selectedProjectID: selectedProjectID.map(ProjectID.init(rawValue:)),
                projects: projects,
                scopedDataByProjectID: scopedData,
                pathAvailabilityByProjectID: pathAvailability,
                nextProjectNumber: nextProjectNumber
            )
        }
    }

    func persistProjectSnapshot(_ snapshot: ProjectRegistryStateSnapshot, storageRoot: URL) throws {
        try withDatabase(storageRoot: storageRoot) { db in
            try persistProjectSnapshot(snapshot, db: db)
        }
    }

    func loadIdeaSnapshot(storageRoot: URL) throws -> IdeaRegistryStateSnapshot? {
        try withDatabase(storageRoot: storageRoot) { db in
            try importLegacyIdeaSnapshotIfNeeded(storageRoot: storageRoot, db: db)

            let ideas = try queryIdeaRecords(db: db)
            let selectedProjectID = try scalarOptionalText(
                "SELECT value FROM registry_metadata WHERE key = 'idea_selected_project_id'",
                db: db
            )
            let nextIdeaNumber = try scalarInt(
                "SELECT COALESCE(CAST(value AS INTEGER), 1) FROM registry_metadata WHERE key = 'idea_next_number'",
                db: db,
                fallback: 1
            )

            guard !ideas.isEmpty || selectedProjectID != nil || nextIdeaNumber != 1 else {
                return nil
            }

            return IdeaRegistryStateSnapshot(
                selectedProjectID: selectedProjectID.map(ProjectID.init(rawValue:)),
                ideas: ideas,
                nextIdeaNumber: nextIdeaNumber
            )
        }
    }

    func persistIdeaSnapshot(_ snapshot: IdeaRegistryStateSnapshot, storageRoot: URL) throws {
        try withDatabase(storageRoot: storageRoot) { db in
            try persistIdeaSnapshot(snapshot, db: db)
        }
    }
}

private extension SQLRegistryStore {
    enum SQLiteValue {
        case text(String)
        case int(Int)
        case bool(Bool)
        case null
    }

    struct LegacyProjectSnapshot: Codable {
        let activeProjectID: String?
        let nextProjectNumber: Int?
        let projects: [LegacyProjectRecord]
        let scopedData: [LegacyScopedData]
    }

    struct LegacyProjectRecord: Codable {
        let id: String
        let name: String
        let localPath: String
        let status: String
        let history: [String]?
        let pathAvailable: Bool?
    }

    struct LegacyScopedData: Codable {
        let id: String
        let ideas: [String]
        let features: [String]
        let progress: [String]
        let metadata: [String: String]
    }

    struct LegacyIdeaSnapshot: Codable {
        let selectedProjectID: String?
        let ideas: [LegacyIdeaRecord]
        let nextIdeaNumber: Int
    }

    struct LegacyIdeaRecord: Codable {
        let id: String
        let projectID: String
        let title: String
        let description: String?
        let status: String
    }

    func withDatabase<T>(storageRoot: URL, _ body: (OpaquePointer) throws -> T) throws -> T {
        try fileManager.createDirectory(at: storageRoot, withIntermediateDirectories: true)

        var db: OpaquePointer?
        guard sqlite3_open(databaseURL(storageRoot: storageRoot).path, &db) == SQLITE_OK, let db else {
            defer { if db != nil { sqlite3_close(db) } }
            throw sqlError("Failed to open SQL registry database", db: db)
        }
        defer { sqlite3_close(db) }

        try migrate(db: db)
        return try body(db)
    }

    func migrate(db: OpaquePointer) throws {
        try execute("PRAGMA journal_mode = WAL", db: db)
        try execute("PRAGMA foreign_keys = ON", db: db)

        try execute(
            """
            CREATE TABLE IF NOT EXISTS registry_metadata (
                key TEXT PRIMARY KEY,
                value TEXT
            )
            """,
            db: db
        )

        try execute(
            """
            CREATE TABLE IF NOT EXISTS registry_projects (
                project_id TEXT PRIMARY KEY,
                sort_order INTEGER NOT NULL,
                name TEXT NOT NULL,
                local_path TEXT NOT NULL,
                status TEXT NOT NULL,
                history_json TEXT NOT NULL,
                path_available INTEGER NOT NULL DEFAULT 1
            )
            """,
            db: db
        )

        try execute(
            """
            CREATE TABLE IF NOT EXISTS registry_project_scoped_data (
                project_id TEXT PRIMARY KEY,
                ideas_json TEXT NOT NULL,
                features_json TEXT NOT NULL,
                progress_json TEXT NOT NULL,
                metadata_json TEXT NOT NULL,
                FOREIGN KEY(project_id) REFERENCES registry_projects(project_id) ON DELETE CASCADE
            )
            """,
            db: db
        )

        try execute(
            """
            CREATE TABLE IF NOT EXISTS registry_ideas (
                idea_id TEXT PRIMARY KEY,
                sort_order INTEGER NOT NULL,
                project_id TEXT NOT NULL,
                title TEXT NOT NULL,
                description TEXT,
                status TEXT NOT NULL
            )
            """,
            db: db
        )

        try upsertMetadata(key: "schema_version", value: "sqlbase-registry/v1", db: db)
    }

    func importLegacyProjectSnapshotIfNeeded(storageRoot: URL, db: OpaquePointer) throws {
        let projectCount = try scalarInt("SELECT COUNT(*) FROM registry_projects", db: db, fallback: 0)
        guard projectCount == 0 else {
            return
        }

        let legacyURL = storageRoot.appendingPathComponent("project-registry-sqlbase.json")
        guard let data = try? Data(contentsOf: legacyURL),
              let snapshot = try? JSONDecoder().decode(LegacyProjectSnapshot.self, from: data)
        else {
            return
        }

        let projects = snapshot.projects.enumerated().map { _, record in
            ProjectRecord(
                id: ProjectID(rawValue: record.id),
                name: record.name,
                localPath: record.localPath,
                status: status(record.status),
                history: record.history ?? []
            )
        }
        let scopedData = Dictionary(
            uniqueKeysWithValues: snapshot.scopedData.map {
                (
                    ProjectID(rawValue: $0.id),
                    ProjectScopedData(
                        ideas: $0.ideas,
                        features: $0.features,
                        progress: $0.progress,
                        metadata: $0.metadata
                    )
                )
            }
        )
        let pathAvailability = Dictionary(
            uniqueKeysWithValues: snapshot.projects.map {
                (ProjectID(rawValue: $0.id), $0.pathAvailable ?? true)
            }
        )
        let nextProjectNumber = max(
            snapshot.nextProjectNumber ?? 1,
            nextProjectNumber(from: projects.map(\.id.rawValue))
        )
        let projectSnapshot = ProjectRegistryStateSnapshot(
            selectedProjectID: snapshot.activeProjectID.map(ProjectID.init(rawValue:)),
            projects: projects,
            scopedDataByProjectID: scopedData,
            pathAvailabilityByProjectID: pathAvailability,
            nextProjectNumber: nextProjectNumber
        )

        try persistProjectSnapshot(projectSnapshot, db: db)
    }

    func importLegacyIdeaSnapshotIfNeeded(storageRoot: URL, db: OpaquePointer) throws {
        let ideaCount = try scalarInt("SELECT COUNT(*) FROM registry_ideas", db: db, fallback: 0)
        guard ideaCount == 0 else {
            return
        }

        let legacyURL = storageRoot.appendingPathComponent("idea-registry-sqlbase.json")
        guard let data = try? Data(contentsOf: legacyURL),
              let snapshot = try? JSONDecoder().decode(LegacyIdeaSnapshot.self, from: data)
        else {
            return
        }

        let ideas = snapshot.ideas.compactMap { record -> IdeaRecord? in
            guard let status = IdeaStatus(rawValue: record.status) else {
                return nil
            }

            return IdeaRecord(
                id: IdeaID(rawValue: record.id),
                projectID: ProjectID(rawValue: record.projectID),
                title: record.title,
                description: record.description,
                status: status
            )
        }

        let nextIdeaNumber = max(snapshot.nextIdeaNumber, nextIdeaNumber(from: ideas.map(\.id.rawValue)))
        let ideaSnapshot = IdeaRegistryStateSnapshot(
            selectedProjectID: snapshot.selectedProjectID.map(ProjectID.init(rawValue:)),
            ideas: ideas,
            nextIdeaNumber: nextIdeaNumber
        )

        try persistIdeaSnapshot(ideaSnapshot, db: db)
    }

    func persistProjectSnapshot(_ snapshot: ProjectRegistryStateSnapshot, db: OpaquePointer) throws {
        try execute("BEGIN IMMEDIATE TRANSACTION", db: db)
        do {
            try execute("DELETE FROM registry_projects", db: db)
            try execute("DELETE FROM registry_project_scoped_data", db: db)

            for (index, project) in snapshot.projects.enumerated() {
                let historyJSON = try jsonString(project.history)
                try execute(
                    """
                    INSERT INTO registry_projects (
                        project_id, sort_order, name, local_path, status, history_json, path_available
                    ) VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    db: db,
                    values: [
                        .text(project.id.rawValue),
                        .int(index),
                        .text(project.name),
                        .text(project.localPath),
                        .text(statusString(project.status)),
                        .text(historyJSON),
                        .bool(snapshot.pathAvailabilityByProjectID[project.id] ?? true),
                    ]
                )
            }

            for (projectID, scopedData) in snapshot.scopedDataByProjectID {
                try execute(
                    """
                    INSERT INTO registry_project_scoped_data (
                        project_id, ideas_json, features_json, progress_json, metadata_json
                    ) VALUES (?, ?, ?, ?, ?)
                    """,
                    db: db,
                    values: [
                        .text(projectID.rawValue),
                        .text(jsonString(scopedData.ideas)),
                        .text(jsonString(scopedData.features)),
                        .text(jsonString(scopedData.progress)),
                        .text(jsonString(scopedData.metadata)),
                    ]
                )
            }

            try upsertMetadata(
                key: "project_active_id",
                value: snapshot.selectedProjectID?.rawValue,
                db: db
            )
            try upsertMetadata(
                key: "project_next_number",
                value: String(snapshot.nextProjectNumber),
                db: db
            )

            try execute("COMMIT", db: db)
        } catch {
            try? execute("ROLLBACK", db: db)
            throw error
        }
    }

    func persistIdeaSnapshot(_ snapshot: IdeaRegistryStateSnapshot, db: OpaquePointer) throws {
        try execute("BEGIN IMMEDIATE TRANSACTION", db: db)
        do {
            try execute("DELETE FROM registry_ideas", db: db)

            for (index, idea) in snapshot.ideas.enumerated() {
                try execute(
                    """
                    INSERT INTO registry_ideas (
                        idea_id, sort_order, project_id, title, description, status
                    ) VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    db: db,
                    values: [
                        .text(idea.id.rawValue),
                        .int(index),
                        .text(idea.projectID.rawValue),
                        .text(idea.title),
                        idea.description.map(SQLiteValue.text) ?? .null,
                        .text(idea.status.rawValue),
                    ]
                )
            }

            try upsertMetadata(
                key: "idea_selected_project_id",
                value: snapshot.selectedProjectID?.rawValue,
                db: db
            )
            try upsertMetadata(
                key: "idea_next_number",
                value: String(snapshot.nextIdeaNumber),
                db: db
            )

            try execute("COMMIT", db: db)
        } catch {
            try? execute("ROLLBACK", db: db)
            throw error
        }
    }

    func queryProjectRecords(db: OpaquePointer) throws -> [ProjectRecord] {
        let sql = """
        SELECT project_id, name, local_path, status, history_json
        FROM registry_projects
        ORDER BY sort_order ASC, project_id ASC
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query registry projects", db: db)
        }
        defer { sqlite3_finalize(statement) }

        var records: [ProjectRecord] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let id = text(at: 0, statement: statement),
                  let name = text(at: 1, statement: statement),
                  let localPath = text(at: 2, statement: statement),
                  let statusValue = text(at: 3, statement: statement),
                  let historyJSON = text(at: 4, statement: statement)
            else {
                continue
            }

            try records.append(
                ProjectRecord(
                    id: ProjectID(rawValue: id),
                    name: name,
                    localPath: localPath,
                    status: status(statusValue),
                    history: decodeJSON(historyJSON, as: [String].self)
                )
            )
        }

        return records
    }

    func queryProjectScopedData(db: OpaquePointer) throws -> [ProjectID: ProjectScopedData] {
        let sql = """
        SELECT project_id, ideas_json, features_json, progress_json, metadata_json
        FROM registry_project_scoped_data
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query project scoped data", db: db)
        }
        defer { sqlite3_finalize(statement) }

        var results: [ProjectID: ProjectScopedData] = [:]
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let id = text(at: 0, statement: statement),
                  let ideasJSON = text(at: 1, statement: statement),
                  let featuresJSON = text(at: 2, statement: statement),
                  let progressJSON = text(at: 3, statement: statement),
                  let metadataJSON = text(at: 4, statement: statement)
            else {
                continue
            }

            results[ProjectID(rawValue: id)] = try ProjectScopedData(
                ideas: decodeJSON(ideasJSON, as: [String].self),
                features: decodeJSON(featuresJSON, as: [String].self),
                progress: decodeJSON(progressJSON, as: [String].self),
                metadata: decodeJSON(metadataJSON, as: [String: String].self)
            )
        }

        return results
    }

    func queryPathAvailability(db: OpaquePointer) throws -> [ProjectID: Bool] {
        let sql = "SELECT project_id, path_available FROM registry_projects"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query project path availability", db: db)
        }
        defer { sqlite3_finalize(statement) }

        var results: [ProjectID: Bool] = [:]
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let id = text(at: 0, statement: statement) else {
                continue
            }
            results[ProjectID(rawValue: id)] = sqlite3_column_int(statement, 1) != 0
        }
        return results
    }

    func queryIdeaRecords(db: OpaquePointer) throws -> [IdeaRecord] {
        let sql = """
        SELECT idea_id, project_id, title, description, status
        FROM registry_ideas
        ORDER BY sort_order ASC, idea_id ASC
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query registry ideas", db: db)
        }
        defer { sqlite3_finalize(statement) }

        var records: [IdeaRecord] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let id = text(at: 0, statement: statement),
                  let projectID = text(at: 1, statement: statement),
                  let title = text(at: 2, statement: statement),
                  let statusValue = text(at: 4, statement: statement),
                  let status = IdeaStatus(rawValue: statusValue)
            else {
                continue
            }

            records.append(
                IdeaRecord(
                    id: IdeaID(rawValue: id),
                    projectID: ProjectID(rawValue: projectID),
                    title: title,
                    description: text(at: 3, statement: statement),
                    status: status
                )
            )
        }

        return records
    }

    func upsertMetadata(key: String, value: String?, db: OpaquePointer) throws {
        try execute(
            """
            INSERT INTO registry_metadata (key, value)
            VALUES (?, ?)
            ON CONFLICT(key) DO UPDATE SET value = excluded.value
            """,
            db: db,
            values: [
                .text(key),
                value.map(SQLiteValue.text) ?? .null,
            ]
        )
    }

    func scalarInt(_ sql: String, db: OpaquePointer, fallback: Int) throws -> Int {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query integer scalar", db: db)
        }
        defer { sqlite3_finalize(statement) }

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return fallback
        }

        if sqlite3_column_type(statement, 0) == SQLITE_NULL {
            return fallback
        }

        return Int(sqlite3_column_int(statement, 0))
    }

    func scalarOptionalText(_ sql: String, db: OpaquePointer) throws -> String? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to query text scalar", db: db)
        }
        defer { sqlite3_finalize(statement) }

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return nil
        }

        return text(at: 0, statement: statement)
    }

    func execute(_ sql: String, db: OpaquePointer, values: [SQLiteValue] = []) throws {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw sqlError("Failed to prepare SQL statement", db: db)
        }
        defer { sqlite3_finalize(statement) }

        try bind(values, to: statement)

        let result = sqlite3_step(statement)
        guard result == SQLITE_DONE || result == SQLITE_ROW else {
            throw sqlError("Failed to execute SQL statement", db: db)
        }
    }

    func bind(_ values: [SQLiteValue], to statement: OpaquePointer?) throws {
        for (offset, value) in values.enumerated() {
            let index = Int32(offset + 1)

            switch value {
            case let .text(textValue):
                sqlite3_bind_text(statement, index, textValue, -1, registrySQLiteTransient)
            case let .int(intValue):
                sqlite3_bind_int(statement, index, Int32(intValue))
            case let .bool(boolValue):
                sqlite3_bind_int(statement, index, boolValue ? 1 : 0)
            case .null:
                sqlite3_bind_null(statement, index)
            }
        }
    }

    func jsonString<T: Encodable>(_ value: T) throws -> String {
        let data = try JSONEncoder().encode(value)
        guard let json = String(data: data, encoding: .utf8) else {
            throw RuntimeError(message: "Failed to encode JSON string for SQL registry persistence.")
        }
        return json
    }

    func decodeJSON<T: Decodable>(_ json: String, as type: T.Type) throws -> T {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(type, from: data)
    }

    func status(_ rawValue: String) -> ProjectStatus {
        rawValue == "archived" ? .archived : .active
    }

    func statusString(_ status: ProjectStatus) -> String {
        switch status {
        case .active:
            return "active"
        case .archived:
            return "archived"
        }
    }

    func nextProjectNumber(from ids: [String]) -> Int {
        nextNumber(from: ids, prefix: "P-")
    }

    func nextIdeaNumber(from ids: [String]) -> Int {
        nextNumber(from: ids, prefix: "I-")
    }

    func nextNumber(from ids: [String], prefix: String) -> Int {
        let maxExisting = ids.compactMap { id -> Int? in
            guard id.hasPrefix(prefix) else {
                return nil
            }
            return Int(id.dropFirst(prefix.count))
        }
        .max() ?? 0

        return maxExisting + 1
    }

    func text(at index: Int32, statement: OpaquePointer?) -> String? {
        guard let cString = sqlite3_column_text(statement, index) else {
            return nil
        }
        return String(cString: cString)
    }

    func sqlError(_ message: String, db: OpaquePointer?) -> RuntimeError {
        let detail = db.flatMap { sqlite3_errmsg($0) }.map { String(cString: $0) } ?? "unknown"
        return RuntimeError(message: "\(message) SQLite error: \(detail)")
    }
}
