import Foundation

struct ProjectBootstrapFileSystem: ProjectBootstrapContract {
    func bootstrapProject(_ input: ProjectBootstrapInput) -> ProjectBootstrapResult {
        let fileManager = FileManager.default

        guard !input.projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ProjectBootstrapResult(
                result: .failure(.init(message: "Project name is required.")),
                projectPath: nil,
                createdPaths: [],
                warnings: []
            )
        }

        guard !input.projectsRootPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ProjectBootstrapResult(
                result: .failure(.init(message: "Projects root path is required.")),
                projectPath: nil,
                createdPaths: [],
                warnings: []
            )
        }

        let projectSlug = slugify(input.projectName)
        let projectURL = URL(fileURLWithPath: input.projectsRootPath).appendingPathComponent(projectSlug)

        if fileManager.fileExists(atPath: projectURL.path),
           let entries = try? fileManager.contentsOfDirectory(atPath: projectURL.path),
           !entries.isEmpty
        {
            return ProjectBootstrapResult(
                result: .failure(.init(message: "Project directory already exists and is not empty.")),
                projectPath: projectURL.path,
                createdPaths: [],
                warnings: []
            )
        }

        var createdPaths: [String] = []
        var warnings: [String] = []

        do {
            let directories = requiredDirectories(for: projectURL)
            for directory in directories {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                createdPaths.append(directory.path)
            }

            try writeTemplates(projectURL: projectURL, input: input, fileManager: fileManager)
            createdPaths.append(contentsOf: writtenFiles(for: projectURL, fileManager: fileManager))

            if input.initializeGitRepository {
                if let gitWarning = initializeGitRepository(projectURL: projectURL) {
                    warnings.append(gitWarning)
                }
            }

            return ProjectBootstrapResult(
                result: .success,
                projectPath: projectURL.path,
                createdPaths: createdPaths,
                warnings: warnings
            )
        } catch {
            return ProjectBootstrapResult(
                result: .failure(.init(message: "Bootstrap failed: \(error.localizedDescription)")),
                projectPath: projectURL.path,
                createdPaths: createdPaths,
                warnings: warnings
            )
        }
    }

    func inspectProject(at path: String) -> ProjectInspectionResult {
        let fileManager = FileManager.default
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else {
            return ProjectInspectionResult(
                result: .failure(.init(message: "Project path is required.")),
                projectPath: path,
                hasAI: false,
                hasScripts: false,
                hasGitRepository: false,
                detectedStorageProfile: nil
            )
        }

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: trimmedPath, isDirectory: &isDirectory), isDirectory.boolValue else {
            return ProjectInspectionResult(
                result: .failure(.init(message: "Project path does not exist or is not a directory.")),
                projectPath: trimmedPath,
                hasAI: false,
                hasScripts: false,
                hasGitRepository: false,
                detectedStorageProfile: nil
            )
        }

        let aiPath = URL(fileURLWithPath: trimmedPath).appendingPathComponent(".ai").path
        let scriptsPath = URL(fileURLWithPath: trimmedPath).appendingPathComponent("Scripts").path
        let gitPath = URL(fileURLWithPath: trimmedPath).appendingPathComponent(".git").path

        let hasAI = fileManager.fileExists(atPath: aiPath)
        let hasScripts = fileManager.fileExists(atPath: scriptsPath)
        let hasGit = fileManager.fileExists(atPath: gitPath)
        let storageProfile = detectStorageProfile(projectPath: trimmedPath, fileManager: fileManager)

        return ProjectInspectionResult(
            result: .success,
            projectPath: trimmedPath,
            hasAI: hasAI,
            hasScripts: hasScripts,
            hasGitRepository: hasGit,
            detectedStorageProfile: storageProfile
        )
    }

    private func requiredDirectories(for projectURL: URL) -> [URL] {
        [
            projectURL,
            projectURL.appendingPathComponent("App"),
            projectURL.appendingPathComponent("Core/Domain"),
            projectURL.appendingPathComponent("Core/Shared"),
            projectURL.appendingPathComponent("Core/Providers"),
            projectURL.appendingPathComponent("Core/Routing"),
            projectURL.appendingPathComponent("Core/Persistence"),
            projectURL.appendingPathComponent("Services"),
            projectURL.appendingPathComponent("Integrations"),
            projectURL.appendingPathComponent("Tests"),
            projectURL.appendingPathComponent("Scripts"),
            projectURL.appendingPathComponent(".ai/prd"),
            projectURL.appendingPathComponent(".ai/stack"),
            projectURL.appendingPathComponent(".ai/features"),
            projectURL.appendingPathComponent(".ai/prompts"),
        ]
    }

    private func writeTemplates(projectURL: URL, input: ProjectBootstrapInput, fileManager: FileManager) throws {
        try write(
            projectURL.appendingPathComponent(".gitignore"),
            """
            # macOS
            .DS_Store

            # Xcode
            DerivedData/
            build/
            *.xcworkspace
            xcuserdata/
            *.xcuserstate

            # Logs
            *.log
            """
        )

        try write(projectURL.appendingPathComponent("Scripts/build.sh"), "#!/bin/bash\nset -e\n\necho \"Configure build script for your stack profile.\"\n")
        try write(projectURL.appendingPathComponent("Scripts/test.sh"), "#!/bin/bash\nset -e\n\necho \"Configure test script for your stack profile.\"\n")
        try write(projectURL.appendingPathComponent("Scripts/lint.sh"), "#!/bin/bash\nset -e\n\necho \"Configure lint script for your stack profile.\"\n")

        let profileJSON = """
        {
          "stack": "\(input.stackProfile)",
          "architecture": "\(input.architectureProfile)",
          "language": "\(input.languageProfile)",
          "execution_style": "\(input.executionStyleProfile)",
          "storage": "\(input.storageProfile.rawValue)"
        }
        """
        try write(projectURL.appendingPathComponent(".ai/project-profile.json"), profileJSON)

        try write(projectURL.appendingPathComponent(".ai/ideas.md"), "- [ ] First idea for this project\n")
        try write(projectURL.appendingPathComponent(".ai/agent.md"), "- Przestrzegaj zasad playbooka\n- Pracuj nad jedną funkcją naraz\n- Nie modyfikuj niepowiązanych plików\n")

        try write(projectURL.appendingPathComponent(".ai/prd/overview.md"), "# Przegląd Produktu\n\n## Podsumowanie\n\nOpisz czym jest produkt, jaki problem rozwiązuje i jakie są jego granice.\n")
        try write(projectURL.appendingPathComponent(".ai/prd/constraints.md"), "# Ograniczenia\n\n## Techniczne\n\n- Opisz kluczowe ograniczenia platformowe i architektoniczne.\n")
        try write(projectURL.appendingPathComponent(".ai/prd/glossary.md"), "# Słownik\n\n## Pojęcia\n\n- Zdefiniuj stabilne terminy domenowe używane w projekcie.\n")

        try write(projectURL.appendingPathComponent(".ai/stack/architecture.md"), "# Architektura\n\nOpisz podział odpowiedzialności modułów.\n")
        try write(projectURL.appendingPathComponent(".ai/stack/shared-code.md"), "# Reguły Kodu Współdzielonego\n\nOpisz zasady extraction i reuse.\n")
        try write(projectURL.appendingPathComponent(".ai/stack/rules.md"), "- Bez force unwrap\n- Bez globalnego mutowalnego stanu\n- Nie modyfikuj niepowiązanych plików\n")

        if input.storageProfile == .sqlbase {
            let stateDirectory = projectURL.appendingPathComponent("State")
            try fileManager.createDirectory(at: stateDirectory, withIntermediateDirectories: true)
            try write(stateDirectory.appendingPathComponent("supervisor.sqlite3"), "")
        }
    }

    private func writtenFiles(for projectURL: URL, fileManager: FileManager) -> [String] {
        var files: [String] = [
            ".gitignore",
            "Scripts/build.sh",
            "Scripts/test.sh",
            "Scripts/lint.sh",
            ".ai/project-profile.json",
            ".ai/ideas.md",
            ".ai/agent.md",
            ".ai/prd/overview.md",
            ".ai/prd/constraints.md",
            ".ai/prd/glossary.md",
            ".ai/stack/architecture.md",
            ".ai/stack/shared-code.md",
            ".ai/stack/rules.md",
        ].map { projectURL.appendingPathComponent($0).path }

        let sqlPath = projectURL.appendingPathComponent("State/supervisor.sqlite3").path
        if fileManager.fileExists(atPath: sqlPath) {
            files.append(sqlPath)
        }

        return files
    }

    private func write(_ url: URL, _ text: String) throws {
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func initializeGitRepository(projectURL: URL) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "init"]
        process.currentDirectoryURL = projectURL

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                return nil
            }
            return "Git init failed with code \(process.terminationStatus)."
        } catch {
            return "Git init failed: \(error.localizedDescription)"
        }
    }

    private func detectStorageProfile(projectPath: String, fileManager: FileManager) -> StorageProfile? {
        let profilePath = URL(fileURLWithPath: projectPath).appendingPathComponent(".ai/project-profile.json")

        if let data = try? Data(contentsOf: profilePath),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let storage = json["storage"]
        {
            return StorageProfile(rawValue: storage)
        }

        let sqlitePath = URL(fileURLWithPath: projectPath).appendingPathComponent("State/supervisor.sqlite3").path
        if fileManager.fileExists(atPath: sqlitePath) {
            return .sqlbase
        }

        let aiPath = URL(fileURLWithPath: projectPath).appendingPathComponent(".ai").path
        if fileManager.fileExists(atPath: aiPath) {
            return .fileAI
        }

        return nil
    }

    private func slugify(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()
        let replaced = lowered.replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
        return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
