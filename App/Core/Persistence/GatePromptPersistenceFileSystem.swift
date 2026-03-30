import Foundation

struct GatePromptPersistenceFileSystem: GatePromptPersistenceContract {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func persistPrompt(_ request: GatePromptPersistenceRequest) -> GatePromptPersistenceResult {
        let trimmedPath = request.projectPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else {
            return GatePromptPersistenceResult(
                result: .failure(.init(message: "Project path is required for persistence.")),
                persistedPath: nil
            )
        }

        let trimmedPrompt = request.promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else {
            return GatePromptPersistenceResult(
                result: .failure(.init(message: "Prompt text is empty; nothing to persist.")),
                persistedPath: nil
            )
        }

        let projectURL = URL(fileURLWithPath: trimmedPath)
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: projectURL.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            return GatePromptPersistenceResult(
                result: .failure(.init(message: "Project path does not exist or is not a directory.")),
                persistedPath: nil
            )
        }

        let operationSlug = slugify(request.operation)
        let timestamp = Self.timestampFormatter.string(from: Date())
        let idea = request.ideaID?.rawValue ?? "no-idea"
        let project = request.projectID?.rawValue ?? "no-project"
        let filename = "\(timestamp)_\(project)_\(idea).md"

        let outputDirectory: URL
        switch request.storageProfile {
        case .fileAI:
            outputDirectory = projectURL.appendingPathComponent(".ai/gates").appendingPathComponent(operationSlug)
        case .sqlbase:
            outputDirectory = projectURL.appendingPathComponent("State/gates").appendingPathComponent(operationSlug)
        }
        let outputURL = outputDirectory.appendingPathComponent(filename)

        do {
            try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

            let payload = """
            operation: \(request.operation)
            project_id: \(project)
            idea_id: \(idea)
            storage: \(request.storageProfile.rawValue)
            ---
            \(trimmedPrompt)
            """
            try payload.write(to: outputURL, atomically: true, encoding: .utf8)

            return GatePromptPersistenceResult(
                result: .success,
                persistedPath: outputURL.path
            )
        } catch {
            return GatePromptPersistenceResult(
                result: .failure(.init(message: "Failed to persist prompt: \(error.localizedDescription)")),
                persistedPath: nil
            )
        }
    }

    private func slugify(_ value: String) -> String {
        let lowered = value.lowercased()
        let replaced = lowered.replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
        return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}
