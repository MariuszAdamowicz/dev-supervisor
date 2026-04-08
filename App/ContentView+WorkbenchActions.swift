import Foundation

extension ContentView {
    func loadWorkbench(for project: WorkspaceProject, idea: IdeaRecord) {
        var nextState = FeatureWorkbenchState()

        nextState.approvedFeatures = loadApprovedFeatures(for: idea, in: project)

        let approvedFeaturesPath = featureArtifactRelativePath(for: idea, fileName: "approved-features.json")
        nextState.approvedFeaturesPath = artifactExists(relativePath: approvedFeaturesPath, in: project)
            ? approvedFeaturesPath
            : nil

        nextState.prdDraft = loadArtifact(
            relativePath: featureArtifactRelativePath(for: idea, fileName: "prd.md"),
            in: project
        ) ?? ""
        nextState.prdArtifactPath = nextState.prdDraft.isEmpty
            ? nil
            : featureArtifactRelativePath(for: idea, fileName: "prd.md")

        nextState.bddDraft = loadArtifact(
            relativePath: featureArtifactRelativePath(for: idea, fileName: "bdd.md"),
            in: project
        ) ?? ""
        nextState.bddArtifactPath = nextState.bddDraft.isEmpty
            ? nil
            : featureArtifactRelativePath(for: idea, fileName: "bdd.md")

        nextState.testsDraft = loadArtifact(
            relativePath: featureArtifactRelativePath(for: idea, fileName: "tests.md"),
            in: project
        ) ?? ""
        nextState.testsArtifactPath = nextState.testsDraft.isEmpty
            ? nil
            : featureArtifactRelativePath(for: idea, fileName: "tests.md")

        nextState.implementationDraft = loadArtifact(
            relativePath: featureArtifactRelativePath(for: idea, fileName: "implementation.md"),
            in: project
        ) ?? ""
        nextState.implementationArtifactPath = nextState.implementationDraft.isEmpty
            ? nil
            : featureArtifactRelativePath(for: idea, fileName: "implementation.md")

        nextState.validationDraft = loadArtifact(
            relativePath: featureArtifactRelativePath(for: idea, fileName: "validation.md"),
            in: project
        ) ?? ""
        nextState.validationArtifactPath = nextState.validationDraft.isEmpty
            ? nil
            : featureArtifactRelativePath(for: idea, fileName: "validation.md")

        let traceabilityPath = featureArtifactRelativePath(for: idea, fileName: "traceability.md")
        nextState.traceabilityPath = artifactExists(relativePath: traceabilityPath, in: project)
            ? traceabilityPath
            : nil
        nextState.selectedStep = nextState.recommendedStep
        workbenchState = nextState
    }

    func generateFeatureSet() {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        ideaToFeaturesService.selectActiveProject(id: project.record.id)
        ideaToFeaturesService.seedIdea(
            id: idea.id,
            projectID: project.record.id,
            title: idea.title,
            status: .selected
        )
        ideaToFeaturesService.setContextAvailability(
            overview: activeInspection?.hasOverview ?? false,
            constraints: activeInspection?.hasConstraints ?? false,
            glossary: activeInspection?.hasGlossary ?? false
        )

        let result = ideaToFeaturesService.generateFeaturesPrompt(for: idea.id)
        workbenchState.featurePromptResult = result
        workbenchState.featurePromptPath = persistPrompt(
            operation: "IDEA -> FEATURES",
            result: result.result,
            promptText: result.promptText,
            idea: idea,
            project: project
        )
        workbenchState.lastMessage = result.result.isSuccess
            ? "Prompt do feature setu jest gotowy. Zatwierdź wynik, jeśli odpowiada intencji idei."
            : errorMessage(from: result.result, fallback: "Nie udało się wygenerować feature setu.")
        rewriteTraceability(for: project, idea: idea)
    }

    func approveFeatureSet() {
        guard let project = selectedProject,
              let idea = selectedIdea,
              let result = workbenchState.featurePromptResult,
              result.result.isSuccess
        else {
            workbenchState.lastMessage = "Najpierw wygeneruj feature set."
            return
        }

        workbenchState.approvedFeatures = result.proposedFeatures

        do {
            let jsonData = try JSONEncoder().encode(result.proposedFeatures)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw RuntimeError(message: "Cannot encode feature set.")
            }

            let jsonPath = featureArtifactRelativePath(for: idea, fileName: "approved-features.json")
            let markdownPath = featureArtifactRelativePath(for: idea, fileName: "feature-set.md")

            workbenchState.approvedFeaturesPath = try persistArtifact(
                relativePath: jsonPath,
                content: jsonString,
                in: project
            )
            _ = try persistArtifact(
                relativePath: markdownPath,
                content: featureSetMarkdown(idea: idea, features: result.proposedFeatures),
                in: project
            )

            updateProjectProgress(for: project, idea: idea, stage: .featureSet)
            workbenchState.selectedStep = .prd
            workbenchState.lastMessage = "Feature set został zapisany i odblokował etap PRD."
            rewriteTraceability(for: project, idea: idea)
        } catch {
            workbenchState.lastMessage = "Nie udało się zapisać feature setu: \(error.localizedDescription)"
        }
    }

    func generatePRDPrompt() {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        featuresToPRDService.selectActiveProject(id: project.record.id)
        featuresToPRDService.setContextAvailability(
            overview: activeInspection?.hasOverview ?? false,
            constraints: activeInspection?.hasConstraints ?? false,
            glossary: activeInspection?.hasGlossary ?? false,
            stackRules: stackRulesAvailable(for: project)
        )

        let result = featuresToPRDService.generatePRDPrompt(
            for: idea.id,
            ideaTitle: idea.title,
            features: workbenchState.approvedFeatures
        )
        workbenchState.prdPromptResult = result
        workbenchState.prdPromptPath = persistPrompt(
            operation: "FEATURES -> PRD",
            result: result.result,
            promptText: result.promptText,
            idea: idea,
            project: project
        )
        workbenchState.lastMessage = result.result.isSuccess
            ? "Prompt PRD jest gotowy. Wklej albo dopracuj dokument po stronie operatora."
            : errorMessage(from: result.result, fallback: "Nie udało się wygenerować promptu PRD.")
        rewriteTraceability(for: project, idea: idea)
    }

    func approvePRD() {
        approveDocument(
            stage: .prd,
            document: workbenchState.prdDraft,
            fileName: "prd.md",
            nextStep: .bdd
        ) { relativePath in
            workbenchState.prdArtifactPath = relativePath
        }
    }

    func generateBDDPrompt() {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        prdToBDDService.selectActiveProject(id: project.record.id)
        prdToBDDService.setContextAvailability(
            overview: activeInspection?.hasOverview ?? false,
            constraints: activeInspection?.hasConstraints ?? false,
            glossary: activeInspection?.hasGlossary ?? false,
            stackRules: stackRulesAvailable(for: project)
        )

        let result = prdToBDDService.generateBDDPrompt(
            for: idea.id,
            ideaTitle: idea.title,
            prdDocument: workbenchState.prdDraft
        )
        workbenchState.bddPromptResult = result
        workbenchState.bddPromptPath = persistPrompt(
            operation: "PRD -> BDD",
            result: result.result,
            promptText: result.promptText,
            idea: idea,
            project: project
        )
        workbenchState.lastMessage = result.result.isSuccess
            ? "Prompt BDD jest gotowy. Dopracuj scenariusze przed przejściem dalej."
            : errorMessage(from: result.result, fallback: "Nie udało się wygenerować promptu BDD.")
        rewriteTraceability(for: project, idea: idea)
    }

    func approveBDD() {
        approveDocument(
            stage: .bdd,
            document: workbenchState.bddDraft,
            fileName: "bdd.md",
            nextStep: .tests
        ) { relativePath in
            workbenchState.bddArtifactPath = relativePath
        }
    }

    func generateTestsPrompt() {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        bddToTestsService.selectActiveProject(id: project.record.id)
        bddToTestsService.setContextAvailability(
            overview: activeInspection?.hasOverview ?? false,
            constraints: activeInspection?.hasConstraints ?? false,
            glossary: activeInspection?.hasGlossary ?? false,
            stackRules: stackRulesAvailable(for: project)
        )

        let result = bddToTestsService.generateTestsPrompt(
            for: idea.id,
            ideaTitle: idea.title,
            bddDocument: workbenchState.bddDraft
        )
        workbenchState.testsPromptResult = result
        workbenchState.testsPromptPath = persistPrompt(
            operation: "BDD -> TESTS",
            result: result.result,
            promptText: result.promptText,
            idea: idea,
            project: project
        )
        workbenchState.lastMessage = result.result.isSuccess
            ? "Prompt testów jest gotowy. Zapisz plan testów jako świadome wejście do implementacji."
            : errorMessage(from: result.result, fallback: "Nie udało się wygenerować promptu testów.")
        rewriteTraceability(for: project, idea: idea)
    }

    func approveTests() {
        approveDocument(
            stage: .tests,
            document: workbenchState.testsDraft,
            fileName: "tests.md",
            nextStep: .implementation
        ) { relativePath in
            workbenchState.testsArtifactPath = relativePath
        }
    }

    func generateImplementationPrompt() {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        testsToImplementationService.selectActiveProject(id: project.record.id)
        testsToImplementationService.setContextAvailability(
            overview: activeInspection?.hasOverview ?? false,
            constraints: activeInspection?.hasConstraints ?? false,
            glossary: activeInspection?.hasGlossary ?? false,
            stackRules: stackRulesAvailable(for: project)
        )

        let result = testsToImplementationService.generateImplementationPrompt(
            for: idea.id,
            ideaTitle: idea.title,
            testsDocument: workbenchState.testsDraft
        )
        workbenchState.implementationPromptResult = result
        workbenchState.implementationPromptPath = persistPrompt(
            operation: "TESTS -> IMPLEMENTATION",
            result: result.result,
            promptText: result.promptText,
            idea: idea,
            project: project
        )
        workbenchState.lastMessage = result.result.isSuccess
            ? "Prompt implementacji jest gotowy. Opisz zakres zmian w kodzie i powiązane testy."
            : errorMessage(from: result.result, fallback: "Nie udało się wygenerować promptu implementacji.")
        rewriteTraceability(for: project, idea: idea)
    }

    func approveImplementation() {
        approveDocument(
            stage: .implementation,
            document: workbenchState.implementationDraft,
            fileName: "implementation.md",
            nextStep: .validation
        ) { relativePath in
            workbenchState.implementationArtifactPath = relativePath
        }
    }

    func generateValidationPrompt() {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        implementationToValidationService.selectActiveProject(id: project.record.id)
        implementationToValidationService.setContextAvailability(
            overview: activeInspection?.hasOverview ?? false,
            constraints: activeInspection?.hasConstraints ?? false,
            glossary: activeInspection?.hasGlossary ?? false,
            stackRules: stackRulesAvailable(for: project)
        )

        let result = implementationToValidationService.generateValidationPrompt(
            for: idea.id,
            ideaTitle: idea.title,
            implementationDocument: workbenchState.implementationDraft
        )
        workbenchState.validationPromptResult = result
        workbenchState.validationPromptPath = persistPrompt(
            operation: "IMPLEMENTATION -> VALIDATION",
            result: result.result,
            promptText: result.promptText,
            idea: idea,
            project: project
        )
        workbenchState.lastMessage = result.result.isSuccess
            ? "Prompt walidacji jest gotowy. Zamknij slice planem testów końcowych i stabilizacji."
            : errorMessage(from: result.result, fallback: "Nie udało się wygenerować promptu walidacji.")
        rewriteTraceability(for: project, idea: idea)
    }

    func approveValidation() {
        approveDocument(
            stage: .validation,
            document: workbenchState.validationDraft,
            fileName: "validation.md",
            nextStep: .validation
        ) { relativePath in
            workbenchState.validationArtifactPath = relativePath
            finalizeIdeaIfNeeded()
        }
    }

    func approveDocument(
        stage: FeatureWorkbenchStep,
        document: String,
        fileName: String,
        nextStep: FeatureWorkbenchStep,
        updatePath: (String) -> Void
    ) {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        let trimmedDocument = document.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDocument.isEmpty else {
            workbenchState.lastMessage = "Nie można zatwierdzić pustego dokumentu dla etapu \(stage.title)."
            return
        }

        do {
            let relativePath = try persistArtifact(
                relativePath: featureArtifactRelativePath(for: idea, fileName: fileName),
                content: trimmedDocument,
                in: project
            )
            updatePath(relativePath)
            updateProjectProgress(for: project, idea: idea, stage: stage)
            workbenchState.selectedStep = nextStep
            workbenchState.lastMessage = "Etap \(stage.title) został zapisany."
            rewriteTraceability(for: project, idea: idea)
        } catch {
            workbenchState.lastMessage = "Nie udało się zapisać etapu \(stage.title): \(error.localizedDescription)"
        }
    }

    func finalizeIdeaIfNeeded() {
        guard let project = selectedProject, let idea = selectedIdea else {
            return
        }

        let registry = ideaRegistryService(for: project.storageProfile)
        registry.selectActiveProject(id: project.record.id)
        _ = registry.changeIdeaStatus(id: idea.id, status: .done)
        refreshIdeas(in: project, retainingSelection: true)
        workbenchState.lastMessage = "Slice został domknięty. Idea otrzymała status done."
    }
}

extension ContentView {
    func stackRulesAvailable(for project: WorkspaceProject) -> Bool {
        artifactExists(relativePath: ".ai/stack/rules.md", in: project)
    }

    func featureArtifactRelativePath(for idea: IdeaRecord, fileName: String) -> String {
        ".ai/features/\(idea.id.rawValue.lowercased())-\(slugify(idea.title))/\(fileName)"
    }

    func loadApprovedFeatures(for idea: IdeaRecord, in project: WorkspaceProject) -> [FeatureCandidate] {
        let relativePath = featureArtifactRelativePath(for: idea, fileName: "approved-features.json")
        guard let content = loadArtifact(relativePath: relativePath, in: project),
              let data = content.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([FeatureCandidate].self, from: data)
        else {
            return []
        }
        return decoded
    }

    func loadArtifact(relativePath: String, in project: WorkspaceProject) -> String? {
        let projectRoot = URL(fileURLWithPath: project.record.localPath)
        let fileURL = projectRoot.appendingPathComponent(relativePath)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return try? String(contentsOf: fileURL, encoding: .utf8)
        }
        guard project.storageProfile == .sqlbase else {
            return nil
        }
        return try? sqlProjectStore.artifactContent(relativePath: relativePath, projectRoot: projectRoot)
    }

    func artifactExists(relativePath: String, in project: WorkspaceProject) -> Bool {
        loadArtifact(relativePath: relativePath, in: project) != nil
    }

    func persistArtifact(relativePath: String, content: String, in project: WorkspaceProject) throws -> String {
        let projectRoot = URL(fileURLWithPath: project.record.localPath)
        let fileURL = projectRoot.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        if project.storageProfile == .sqlbase {
            _ = try sqlProjectStore.storeArtifactFile(at: fileURL, projectRoot: projectRoot)
        }
        return relativePath
    }

    func persistPrompt(
        operation: String,
        result: RegistryOperationResult,
        promptText: String,
        idea: IdeaRecord,
        project: WorkspaceProject
    ) -> String? {
        guard result.isSuccess else {
            return nil
        }

        let request = GatePromptPersistenceRequest(
            projectPath: project.record.localPath,
            storageProfile: project.storageProfile,
            operation: operation,
            ideaID: idea.id,
            projectID: project.record.id,
            promptText: promptText
        )
        let persistence = gatePersistenceService.persistPrompt(request)
        guard persistence.result.isSuccess else {
            workbenchState.lastMessage = errorMessage(
                from: persistence.result,
                fallback: "Nie udało się zapisać promptu."
            )
            return nil
        }
        return persistence.persistedPath
    }

    func updateProjectProgress(for project: WorkspaceProject, idea: IdeaRecord, stage: FeatureWorkbenchStep) {
        let registry = projectRegistryService(for: project.storageProfile)
        let current = registry.scopedData(for: project.record.id) ?? ProjectScopedData(
            ideas: [],
            features: [],
            progress: [],
            metadata: [:]
        )

        let nextIdeas = uniqued([idea.id.rawValue] + current.ideas)
        let nextFeatures = uniqued(
            workbenchState.approvedFeatures.map { "\($0.key): \($0.name)" } + current.features
        )
        let nextProgress = uniqued(["\(idea.id.rawValue):\(stage.rawValue)"] + current.progress)
        var metadata = current.metadata
        metadata["feature_workbench.idea_id"] = idea.id.rawValue
        metadata["feature_workbench.current_step"] = workbenchState.recommendedStep.rawValue

        registry.seedScopedData(
            for: project.record.id,
            data: ProjectScopedData(
                ideas: nextIdeas,
                features: nextFeatures,
                progress: nextProgress,
                metadata: metadata
            )
        )
    }

    func rewriteTraceability(for project: WorkspaceProject, idea: IdeaRecord) {
        let content = traceabilityMarkdown(project: project, idea: idea)
        do {
            workbenchState.traceabilityPath = try persistArtifact(
                relativePath: featureArtifactRelativePath(for: idea, fileName: "traceability.md"),
                content: content,
                in: project
            )
        } catch {
            workbenchState.lastMessage = "Nie udało się zaktualizować traceability: \(error.localizedDescription)"
        }
    }

    func traceabilityMarkdown(project: WorkspaceProject, idea: IdeaRecord) -> String {
        let rows = [
            traceabilityRow(
                label: "feature_set",
                ready: !workbenchState.approvedFeatures.isEmpty,
                artifactPath: workbenchState.approvedFeaturesPath,
                promptPath: workbenchState.featurePromptPath
            ),
            traceabilityRow(
                label: "prd",
                ready: !workbenchState.prdDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                artifactPath: workbenchState.prdArtifactPath,
                promptPath: workbenchState.prdPromptPath
            ),
            traceabilityRow(
                label: "bdd",
                ready: !workbenchState.bddDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                artifactPath: workbenchState.bddArtifactPath,
                promptPath: workbenchState.bddPromptPath
            ),
            traceabilityRow(
                label: "tests",
                ready: !workbenchState.testsDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                artifactPath: workbenchState.testsArtifactPath,
                promptPath: workbenchState.testsPromptPath
            ),
            traceabilityRow(
                label: "implementation",
                ready: !workbenchState.implementationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                artifactPath: workbenchState.implementationArtifactPath,
                promptPath: workbenchState.implementationPromptPath
            ),
            traceabilityRow(
                label: "validation",
                ready: !workbenchState.validationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                artifactPath: workbenchState.validationArtifactPath,
                promptPath: workbenchState.validationPromptPath
            ),
        ]

        return """
        # Traceability

        - project_id: \(project.record.id.rawValue)
        - project_name: \(project.record.name)
        - storage: \(project.storageProfile.rawValue)
        - idea_id: \(idea.id.rawValue)
        - idea_title: \(idea.title)
        - idea_status: \(idea.status.rawValue)
        - next_step: \(workbenchState.recommendedStep.rawValue)

        ## Stage Status
        \(rows.joined(separator: "\n"))
        """
    }

    func traceabilityRow(label: String, ready: Bool, artifactPath: String?, promptPath: String?) -> String {
        [
            "- stage: \(label)",
            "  ready: \(ready ? "yes" : "no")",
            "  artifact: \(artifactPath ?? "n/a")",
            "  prompt: \(promptPath ?? "n/a")",
        ].joined(separator: "\n")
    }

    func featureSetMarkdown(idea: IdeaRecord, features: [FeatureCandidate]) -> String {
        let rows = features
            .map { "- \($0.key): \($0.name) | \($0.description)" }
            .joined(separator: "\n")
        return """
        # Feature Set

        - idea_id: \(idea.id.rawValue)
        - idea_title: \(idea.title)

        ## Approved Features
        \(rows)
        """
    }

    func slugify(_ value: String) -> String {
        let lowered = value.lowercased()
        let replaced = lowered.replacingOccurrences(
            of: "[^a-z0-9]+",
            with: "-",
            options: .regularExpression
        )
        return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    func uniqued(_ items: [String]) -> [String] {
        items.reduce(into: [String]()) { result, item in
            if !result.contains(item) {
                result.append(item)
            }
        }
    }
}
