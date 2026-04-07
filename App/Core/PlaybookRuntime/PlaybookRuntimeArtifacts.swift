import Foundation

extension PlaybookRuntimeFileSystem {
    func ensureProjectDirectoryReady(_ projectURL: URL) throws {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: projectURL.path, isDirectory: &isDirectory) {
            guard isDirectory.boolValue else {
                throw RuntimeError(message: "Project path exists and is not a directory.")
            }

            let entries = try fileManager.contentsOfDirectory(atPath: projectURL.path)
            guard entries.isEmpty else {
                throw RuntimeError(message: "Project directory already exists and is not empty.")
            }
        }
    }

    func createProjectScaffold(_ projectURL: URL, request: PlaybookNewProjectRequest) throws -> [String] {
        let directories = projectDirectories(for: projectURL)
        var createdArtifacts: [String] = []

        for directory in directories {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            createdArtifacts.append(directory.path)
        }

        try createdArtifacts.append(contentsOf: createStorageArtifactsIfNeeded(projectURL, profile: request.profileSelection))
        try createdArtifacts.append(contentsOf: writeProjectFiles(projectURL, request: request))
        return createdArtifacts
    }

    func writePlaybookInstance(at projectURL: URL, projectName: String, profile: PlaybookProfileSelection) throws -> String {
        let playbookInstanceURL = projectURL.appendingPathComponent(".ai/runtime/v1/playbook-instance.json")
        let payload = makeJSONString([
            "schema_version": .string("ds-playbook-instance/v1"),
            "playbook_instance_id": .string("playbook.instance"),
            "project_name": .string(projectName),
            "profiles": .object([
                "stack": .string(profile.stack),
                "architecture": .string(profile.architecture),
                "language": .string(profile.language),
                "execution_style": .string(profile.executionStyle),
                "storage": .string(profile.storage.rawValue),
            ]),
            "source_exec_spec": .string("playbook/runtime/playbook-exec.yaml"),
            "created_at": .string(timestamp()),
        ])
        try payload.write(to: playbookInstanceURL, atomically: true, encoding: .utf8)
        return playbookInstanceURL.path
    }

    func writeFeatureArtifacts(
        projectRoot: URL,
        ideaTitle: String,
        ideaDescription: String,
        derivedOps: [PlaybookDerivedOPSummary]
    ) throws -> [String] {
        let featureRoot = projectRoot.appendingPathComponent(".ai/features/\(slugify(ideaTitle))")
        try fileManager.createDirectory(at: featureRoot, withIntermediateDirectories: true)

        let files = featureArtifactsContent(
            ideaTitle: ideaTitle,
            ideaDescription: ideaDescription,
            derivedOps: derivedOps
        )

        var createdArtifacts: [String] = []
        for (name, content) in files {
            let fileURL = featureRoot.appendingPathComponent(name)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            createdArtifacts.append(fileURL.path)
        }
        return createdArtifacts
    }

    func buildDerivedDefinitions(for ideaTitle: String, description: String, ideaID: String) -> [RuntimeDerivedDefinition] {
        let slug = slugify(ideaTitle)
        let normalizedDescription = description.isEmpty ? "Brak opisu." : description
        let primaryTerm = extractedTerms(from: "\(ideaTitle) \(description)").first ?? ideaTitle
        let baseLinks = [
            RuntimeLink(rel: "source_idea", target: ideaID),
            RuntimeLink(rel: "parent", target: "project.ds"),
        ]

        return [
            RuntimeDerivedDefinition(
                opID: uniqueOpID(base: "feature.\(slug)"),
                opType: "Feature",
                initialState: "drafted",
                links: baseLinks,
                tags: ["generated_from:idea"],
                payload: [
                    "scope": .string(normalizedDescription),
                    "title": .string(ideaTitle),
                ]
            ),
            RuntimeDerivedDefinition(
                opID: uniqueOpID(base: "requirement.\(slug)"),
                opType: "Requirement",
                initialState: "proposed",
                links: baseLinks,
                tags: ["generated_from:idea"],
                payload: [
                    "source": .string("Idea"),
                    "priority": .string("P1"),
                    "acceptance_criteria": .array([
                        .string("Operator can start project flow from UI."),
                        .string("Audit trail is written under .ai/runtime/v1."),
                    ]),
                ]
            ),
            RuntimeDerivedDefinition(
                opID: uniqueOpID(base: "term.\(slug)"),
                opType: "Term",
                initialState: "proposed",
                links: baseLinks,
                tags: ["generated_from:idea"],
                payload: [
                    "term": .string(primaryTerm),
                    "definition": .string("Termin wygenerowany z pierwszej idei: \(ideaTitle)"),
                ]
            ),
            RuntimeDerivedDefinition(
                opID: uniqueOpID(base: "prompttask.\(slug)"),
                opType: "PromptTask",
                initialState: "created",
                links: [
                    RuntimeLink(rel: "target_op", target: "feature.\(slug)"),
                    RuntimeLink(rel: "source_idea", target: ideaID),
                ],
                tags: ["generated_from:idea", "task:idea-to-feature-and-terms"],
                payload: [
                    "task_type": .string("idea-to-feature-and-terms"),
                    "context_set": .array([
                        .string(".ai/prd/overview.md"),
                        .string(".ai/prd/constraints.md"),
                        .string(".ai/prd/glossary.md"),
                    ]),
                ]
            ),
        ]
    }
}

extension PlaybookRuntimeFileSystem {
    func projectDirectories(for projectURL: URL) -> [URL] {
        [
            projectURL,
            projectURL.appendingPathComponent("App"),
            projectURL.appendingPathComponent("Tests"),
            projectURL.appendingPathComponent("Scripts"),
            projectURL.appendingPathComponent(".ai/prd"),
            projectURL.appendingPathComponent(".ai/features"),
            projectURL.appendingPathComponent(".ai/stack"),
            projectURL.appendingPathComponent(".ai/runtime/v1/ops"),
        ]
    }

    func createStorageArtifactsIfNeeded(_ projectURL: URL, profile: PlaybookProfileSelection) throws -> [String] {
        guard profile.storage == .sqlbase else {
            return []
        }

        let stateDirectory = projectURL.appendingPathComponent("State")
        try fileManager.createDirectory(at: stateDirectory, withIntermediateDirectories: true)

        let sqlitePath = stateDirectory.appendingPathComponent("supervisor.sqlite3")
        try Data().write(to: sqlitePath, options: .atomic)
        return [stateDirectory.path, sqlitePath.path]
    }

    func writeProjectFiles(_ projectURL: URL, request: PlaybookNewProjectRequest) throws -> [String] {
        let files = projectFileTemplates(projectURL: projectURL, request: request)
        var createdArtifacts: [String] = []

        for (url, content) in files {
            try content.write(to: url, atomically: true, encoding: .utf8)
            createdArtifacts.append(url.path)
        }
        return createdArtifacts
    }

    func projectFileTemplates(projectURL: URL, request: PlaybookNewProjectRequest) -> [(URL, String)] {
        let profile = request.profileSelection
        let profileJSON = makeJSONString([
            "stack": .string(profile.stack),
            "architecture": .string(profile.architecture),
            "language": .string(profile.language),
            "execution_style": .string(profile.executionStyle),
            "storage": .string(profile.storage.rawValue),
        ])

        return [
            (projectURL.appendingPathComponent(".gitignore"), gitignoreTemplate()),
            (projectURL.appendingPathComponent("Scripts/build.sh"), buildScript(for: profile.stack)),
            (projectURL.appendingPathComponent("Scripts/test.sh"), testScript(for: profile.stack)),
            (projectURL.appendingPathComponent("Scripts/lint.sh"), lintScript(for: profile.stack)),
            (projectURL.appendingPathComponent(".ai/project-profile.json"), profileJSON),
            (projectURL.appendingPathComponent(".ai/prd/overview.md"), overviewMarkdown(name: request.projectName, description: request.projectDescription, profile: profile)),
            (projectURL.appendingPathComponent(".ai/prd/constraints.md"), constraintsMarkdown(profile: profile)),
            (projectURL.appendingPathComponent(".ai/prd/glossary.md"), glossaryMarkdown(projectName: request.projectName, description: request.projectDescription)),
            (projectURL.appendingPathComponent(".ai/stack/rules.md"), stackRulesMarkdown(profile: profile)),
        ]
    }

    func featureArtifactsContent(
        ideaTitle: String,
        ideaDescription: String,
        derivedOps: [PlaybookDerivedOPSummary]
    ) -> [(String, String)] {
        let featureOps = Dictionary(uniqueKeysWithValues: derivedOps.map { ($0.opType, $0.opID) })

        return [
            (
                "prd.md",
                """
                # PRD

                ## Idea
                - title: \(ideaTitle)
                - description: \(ideaDescription.isEmpty ? "Brak opisu." : ideaDescription)

                ## Generated OP
                - Feature: \(featureOps["Feature"] ?? "n/a")
                - Requirement: \(featureOps["Requirement"] ?? "n/a")
                - Term: \(featureOps["Term"] ?? "n/a")
                """
            ),
            (
                "bdd.md",
                """
                # BDD

                Scenario: Start project and keep first idea visible in runtime.
                Given an active project
                When the operator adds the first idea
                Then DevSupervisor creates derived OP and audit trail
                """
            ),
            (
                "notes.md",
                """
                # Notes

                - Feature folder created directly from `add_idea`.
                - First implementation target is deterministic runtime bootstrap.
                """
            ),
            (
                "tasks.md",
                """
                # Tasks

                - [x] Create derived OP
                - [x] Create audit trail
                - [ ] Expand downstream Feature workflow
                """
            ),
            (
                "traceability.md",
                """
                # Traceability

                - Requirement -> first idea captured from UI
                - Scenario -> Start project and add first idea
                - Test -> PlaybookRuntimeFileSystemTests
                """
            ),
        ]
    }

    func uniqueOpID(base: String) -> String {
        base
    }

    func gitignoreTemplate() -> String {
        """
        # macOS
        .DS_Store

        # Build
        build/
        DerivedData/

        # Logs
        *.log
        """
    }

    func buildScript(for stack: String) -> String {
        guard stack == "macos-swiftui" else {
            return genericScriptTemplate(stack: stack, action: "build")
        }

        return """
        #!/bin/bash
        set -e

        SCHEME="$(basename "$(pwd)")"

        xcodebuild \
          -scheme "$SCHEME" \
          -configuration Debug \
          build 2>&1 | tee build.log

        grep -E "error:" build.log || true
        """
    }

    func testScript(for stack: String) -> String {
        guard stack == "macos-swiftui" else {
            return genericScriptTemplate(stack: stack, action: "test")
        }

        return """
        #!/bin/bash
        set -e

        SCHEME="$(basename "$(pwd)")"

        xcodebuild \
          test \
          -scheme "$SCHEME" \
          -destination 'platform=macOS'
        """
    }

    func lintScript(for stack: String) -> String {
        guard stack == "macos-swiftui" else {
            return genericScriptTemplate(stack: stack, action: "lint")
        }

        return """
        #!/bin/bash
        set -e
        swiftlint
        swiftformat .
        """
    }

    func genericScriptTemplate(stack: String, action: String) -> String {
        """
        #!/bin/bash
        set -e
        echo "Configure \(action) script for stack profile: \(stack)"
        """
    }

    func overviewMarkdown(name: String, description: String, profile: PlaybookProfileSelection) -> String {
        """
        # Product Overview

        ## Project
        - name: \(name)
        - stack: \(profile.stack)
        - architecture: \(profile.architecture)
        - language: \(profile.language)
        - execution-style: \(profile.executionStyle)
        - storage: \(profile.storage.rawValue)

        ## Summary
        \(description)

        ## First runtime target
        - uruchomienie projektu przez UI
        - baseline `.ai/prd/*`
        - instancja `OP.Project`
        """
    }

    func constraintsMarkdown(profile: PlaybookProfileSelection) -> String {
        """
        # Constraints

        ## Stack
        - \(profile.stack)
        - \(profile.architecture)

        ## Language
        - \(profile.language)
        - execution-style: \(profile.executionStyle)

        ## Persistence
        - storage profile: \(profile.storage.rawValue)
        - audit trail under `.ai/runtime/v1`

        ## Quality
        - build/test/lint must pass before merge
        - no silent transitions
        """
    }

    func glossaryMarkdown(projectName: String, description: String) -> String {
        let terms = ([projectName] + extractedTerms(from: description) + ["OP", "GateDecision", "ProcessEvent"])
            .reduce(into: [String]()) { acc, term in
                if !acc.contains(term) {
                    acc.append(term)
                }
            }

        let bullets = terms.map { "- \($0)" }.joined(separator: "\n")
        return "# Glossary\n\n\(bullets)\n"
    }

    func extractedTerms(from text: String) -> [String] {
        let rawTokens = text
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 3 }

        return rawTokens.reduce(into: [String]()) { acc, token in
            let normalized: String
            if token == token.uppercased() {
                normalized = token
            } else {
                normalized = token.prefix(1).uppercased() + token.dropFirst().lowercased()
            }

            if !acc.contains(normalized) {
                acc.append(normalized)
            }
        }
        .prefix(6)
        .map { $0 }
    }

    func stackRulesMarkdown(profile: PlaybookProfileSelection) -> String {
        """
        # Stack Rules

        - stack: \(profile.stack)
        - architecture: \(profile.architecture)
        - execution-style: \(profile.executionStyle)
        - storage: \(profile.storage.rawValue)
        - no silent transitions
        - explicit gate decisions only
        """
    }

    func slugify(_ value: String) -> String {
        let lowered = value.lowercased()
        let replaced = lowered.replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
        return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
