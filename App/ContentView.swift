import SwiftUI

struct ContentView: View {
    @State private var projectName = ""
    @State private var projectsRootPath = ""
    @State private var selectedStorageProfile: StorageProfile = .fileAI
    @State private var initializeGitRepository = true

    @State private var inspectPath = ""

    @State private var lastBootstrapResult: ProjectBootstrapResult?
    @State private var lastInspectionResult: ProjectInspectionResult?
    @State private var flowProjectID = "P-1"
    @State private var flowIdeaID = "I-1"
    @State private var flowIdeaTitle = ""
    @State private var flowIdeaStatus: IdeaStatus = .selected
    @State private var prdDocumentText = ""
    @State private var bddDocumentText = ""
    @State private var testsDocumentText = ""
    @State private var implementationDocumentText = ""
    @State private var lastFeaturesResult: FeatureSetPromptGenerationResult?
    @State private var lastPRDFromFeaturesResult: PRDFromFeaturesPromptResult?
    @State private var lastBDDFromPRDResult: BDDFromPRDPromptResult?
    @State private var lastTestsFromBDDResult: TestsFromBDDPromptResult?
    @State private var lastImplementationFromTestsResult: ImplementationFromTestsPromptResult?
    @State private var lastValidationFromImplementationResult: ValidationFromImplementationPromptResult?

    private let bootstrapService: any ProjectBootstrapContract = ProjectBootstrapFileSystem()
    private let ideaToFeaturesService: any IdeaToFeaturesFlowContract = IdeaToFeaturesFlowInMemory()
    private let featuresToPRDService: any FeaturesToPRDFlowContract = FeaturesToPRDFlowInMemory()
    private let prdToBDDService: any PRDToBDDFlowContract = PRDToBDDFlowInMemory()
    private let bddToTestsService: any BDDToTestsFlowContract = BDDToTestsFlowInMemory()
    private let testsToImplementationService: any TestsToImplementationFlowContract = TestsToImplementationFlowInMemory()
    private let implementationToValidationService: any ImplementationToValidationFlowContract = ImplementationToValidationFlowInMemory()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Dev Supervisor")
                    .font(.largeTitle.bold())
                Text("Deterministyczny bootstrap i inspekcja projektu")
                    .foregroundStyle(.secondary)

                newProjectSection
                Divider()
                ideaToFeaturesSection
                Divider()
                featuresToPRDSection
                Divider()
                prdToBDDSection
                Divider()
                bddToTestsSection
                Divider()
                testsToImplementationSection
                Divider()
                implementationToValidationSection
                Divider()
                inspectProjectSection
                Divider()
                statusSection
            }
            .padding(24)
        }
        .frame(minWidth: 860, minHeight: 640)
        .onAppear {
            if projectsRootPath.isEmpty {
                projectsRootPath = defaultProjectsRootPath()
            }
        }
    }

    private var newProjectSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nowy projekt")
                .font(.title2.bold())

            TextField("Nazwa projektu (np. Dev Supervisor)", text: $projectName)
                .textFieldStyle(.roundedBorder)

            TextField("Katalog główny na projekty", text: $projectsRootPath)
                .textFieldStyle(.roundedBorder)

            Picker("Storage profile", selection: $selectedStorageProfile) {
                Text("file-ai").tag(StorageProfile.fileAI)
                Text("sqlbase").tag(StorageProfile.sqlbase)
            }
            .pickerStyle(.segmented)

            Toggle("Zainicjalizuj git repo", isOn: $initializeGitRepository)

            Button("Bootstrap project") {
                let input = ProjectBootstrapInput(
                    projectName: projectName,
                    projectsRootPath: projectsRootPath,
                    storageProfile: selectedStorageProfile,
                    initializeGitRepository: initializeGitRepository
                )
                lastBootstrapResult = bootstrapService.bootstrapProject(input)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var ideaToFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IDEA -> FEATURES")
                .font(.title2.bold())

            Text("Gate operatora: materializacja wybranej idei do zestawu funkcjonalności przed PRD.")
                .foregroundStyle(.secondary)

            TextField("Project ID", text: $flowProjectID)
                .textFieldStyle(.roundedBorder)

            TextField("Idea ID", text: $flowIdeaID)
                .textFieldStyle(.roundedBorder)

            TextField("Idea title", text: $flowIdeaTitle)
                .textFieldStyle(.roundedBorder)

            Picker("Idea status", selection: $flowIdeaStatus) {
                Text("new").tag(IdeaStatus.new)
                Text("selected").tag(IdeaStatus.selected)
                Text("deferred").tag(IdeaStatus.deferred)
                Text("done").tag(IdeaStatus.done)
            }
            .pickerStyle(.segmented)

            Button("Generate IDEA -> FEATURES prompt") {
                let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaID = IdeaID(rawValue: flowIdeaID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaTitle = flowIdeaTitle.trimmingCharacters(in: .whitespacesAndNewlines)

                ideaToFeaturesService.selectActiveProject(id: projectID)
                ideaToFeaturesService.seedIdea(
                    id: ideaID,
                    projectID: projectID,
                    title: ideaTitle,
                    status: flowIdeaStatus
                )
                ideaToFeaturesService.setContextAvailability(
                    overview: true,
                    constraints: true,
                    glossary: true
                )

                lastFeaturesResult = ideaToFeaturesService.generateFeaturesPrompt(for: ideaID)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var featuresToPRDSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FEATURES -> PRD")
                .font(.title2.bold())

            Text("Gate operatora: budowa promptu PRD na bazie wygenerowanego feature-setu.")
                .foregroundStyle(.secondary)

            Button("Generate FEATURES -> PRD prompt") {
                guard let featuresResult = lastFeaturesResult, featuresResult.result.isSuccess else {
                    lastPRDFromFeaturesResult = PRDFromFeaturesPromptResult(
                        result: .failure(.init(message: "Run IDEA -> FEATURES successfully before this step.")),
                        promptText: "",
                        promptFingerprint: "",
                        includesMinimalContext: false,
                        ideaID: nil,
                        projectID: nil,
                        featuresCount: 0
                    )
                    return
                }

                let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaID = IdeaID(rawValue: flowIdeaID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaTitle = flowIdeaTitle.trimmingCharacters(in: .whitespacesAndNewlines)

                featuresToPRDService.selectActiveProject(id: projectID)
                featuresToPRDService.setContextAvailability(
                    overview: true,
                    constraints: true,
                    glossary: true,
                    stackRules: true
                )

                lastPRDFromFeaturesResult = featuresToPRDService.generatePRDPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    features: featuresResult.proposedFeatures
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var prdToBDDSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PRD -> BDD")
                .font(.title2.bold())

            Text("Gate operatora: budowa promptu BDD na bazie zatwierdzonego dokumentu PRD.")
                .foregroundStyle(.secondary)

            TextEditor(text: $prdDocumentText)
                .font(.footnote.monospaced())
                .frame(minHeight: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

            Button("Generate PRD -> BDD prompt") {
                guard let prdResult = lastPRDFromFeaturesResult, prdResult.result.isSuccess else {
                    lastBDDFromPRDResult = BDDFromPRDPromptResult(
                        result: .failure(.init(message: "Run FEATURES -> PRD successfully before this step.")),
                        promptText: "",
                        promptFingerprint: "",
                        includesMinimalContext: false,
                        ideaID: nil,
                        projectID: nil,
                        prdLength: 0
                    )
                    return
                }

                let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaID = IdeaID(rawValue: flowIdeaID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaTitle = flowIdeaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let candidatePRD = prdDocumentText.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalPRDDocument = candidatePRD.isEmpty ? prdResult.promptText : candidatePRD

                prdToBDDService.selectActiveProject(id: projectID)
                prdToBDDService.setContextAvailability(
                    overview: true,
                    constraints: true,
                    glossary: true,
                    stackRules: true
                )

                lastBDDFromPRDResult = prdToBDDService.generateBDDPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    prdDocument: finalPRDDocument
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var bddToTestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BDD -> TESTY")
                .font(.title2.bold())

            Text("Gate operatora: budowa promptu testów na bazie zatwierdzonego dokumentu BDD.")
                .foregroundStyle(.secondary)

            TextEditor(text: $bddDocumentText)
                .font(.footnote.monospaced())
                .frame(minHeight: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

            Button("Generate BDD -> TESTS prompt") {
                guard let bddResult = lastBDDFromPRDResult, bddResult.result.isSuccess else {
                    lastTestsFromBDDResult = TestsFromBDDPromptResult(
                        result: .failure(.init(message: "Run PRD -> BDD successfully before this step.")),
                        promptText: "",
                        promptFingerprint: "",
                        includesMinimalContext: false,
                        ideaID: nil,
                        projectID: nil,
                        bddLength: 0
                    )
                    return
                }

                let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaID = IdeaID(rawValue: flowIdeaID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaTitle = flowIdeaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let candidateBDD = bddDocumentText.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalBDDDoc = candidateBDD.isEmpty ? bddResult.promptText : candidateBDD

                bddToTestsService.selectActiveProject(id: projectID)
                bddToTestsService.setContextAvailability(
                    overview: true,
                    constraints: true,
                    glossary: true,
                    stackRules: true
                )

                lastTestsFromBDDResult = bddToTestsService.generateTestsPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    bddDocument: finalBDDDoc
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var inspectProjectSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Otwórz istniejący projekt")
                .font(.title2.bold())

            TextField("Ścieżka do projektu", text: $inspectPath)
                .textFieldStyle(.roundedBorder)

            Button("Inspect project") {
                lastInspectionResult = bootstrapService.inspectProject(at: inspectPath)
            }
            .buttonStyle(.bordered)
        }
    }

    private func defaultProjectsRootPath() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Projects"
    }
}

private extension ContentView {
    var testsToImplementationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TESTY -> IMPLEMENTACJA")
                .font(.title2.bold())

            Text("Gate operatora: budowa promptu implementacji na bazie zatwierdzonego dokumentu testów.")
                .foregroundStyle(.secondary)

            TextEditor(text: $testsDocumentText)
                .font(.footnote.monospaced())
                .frame(minHeight: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

            Button("Generate TESTS -> IMPLEMENTATION prompt") {
                guard let testsResult = lastTestsFromBDDResult, testsResult.result.isSuccess else {
                    lastImplementationFromTestsResult = ImplementationFromTestsPromptResult(
                        result: .failure(.init(message: "Run BDD -> TESTS successfully before this step.")),
                        promptText: "",
                        promptFingerprint: "",
                        includesMinimalContext: false,
                        ideaID: nil,
                        projectID: nil,
                        testsLength: 0
                    )
                    return
                }

                let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaID = IdeaID(rawValue: flowIdeaID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaTitle = flowIdeaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let candidateTests = testsDocumentText.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalTestsDoc = candidateTests.isEmpty ? testsResult.promptText : candidateTests

                testsToImplementationService.selectActiveProject(id: projectID)
                testsToImplementationService.setContextAvailability(
                    overview: true,
                    constraints: true,
                    glossary: true,
                    stackRules: true
                )

                lastImplementationFromTestsResult = testsToImplementationService.generateImplementationPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    testsDocument: finalTestsDoc
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var implementationToValidationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IMPLEMENTACJA -> WALIDACJA")
                .font(.title2.bold())

            Text("Gate operatora: budowa promptu walidacji i stabilizacji na bazie opisu implementacji.")
                .foregroundStyle(.secondary)

            TextEditor(text: $implementationDocumentText)
                .font(.footnote.monospaced())
                .frame(minHeight: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

            Button("Generate IMPLEMENTATION -> VALIDATION prompt") {
                guard let implementationResult = lastImplementationFromTestsResult, implementationResult.result.isSuccess else {
                    lastValidationFromImplementationResult = ValidationFromImplementationPromptResult(
                        result: .failure(.init(message: "Run TESTS -> IMPLEMENTATION successfully before this step.")),
                        promptText: "",
                        promptFingerprint: "",
                        includesMinimalContext: false,
                        ideaID: nil,
                        projectID: nil,
                        implementationLength: 0
                    )
                    return
                }

                let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaID = IdeaID(rawValue: flowIdeaID.trimmingCharacters(in: .whitespacesAndNewlines))
                let ideaTitle = flowIdeaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let candidateImplementation = implementationDocumentText.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalImplementationDoc = candidateImplementation.isEmpty ? implementationResult.promptText : candidateImplementation

                implementationToValidationService.selectActiveProject(id: projectID)
                implementationToValidationService.setContextAvailability(
                    overview: true,
                    constraints: true,
                    glossary: true,
                    stackRules: true
                )

                lastValidationFromImplementationResult = implementationToValidationService.generateValidationPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    implementationDocument: finalImplementationDoc
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.title2.bold())

            if let bootstrap = lastBootstrapResult {
                Text("Bootstrap: \(statusText(for: bootstrap.result))")
                if let path = bootstrap.projectPath {
                    Text("Project path: \(path)")
                        .font(.footnote)
                }
                if !bootstrap.createdPaths.isEmpty {
                    Text("Created entries: \(bootstrap.createdPaths.count)")
                        .font(.footnote)
                }
                if !bootstrap.warnings.isEmpty {
                    ForEach(bootstrap.warnings, id: \.self) { warning in
                        Text("Warning: \(warning)")
                            .foregroundStyle(.orange)
                            .font(.footnote)
                    }
                }
            }

            if let inspection = lastInspectionResult {
                Text("Inspect: \(statusText(for: inspection.result))")
                Text("Path: \(inspection.projectPath)")
                    .font(.footnote)
                Text(".ai: \(inspection.hasAI ? "yes" : "no") | Scripts: \(inspection.hasScripts ? "yes" : "no") | Git: \(inspection.hasGitRepository ? "yes" : "no")")
                    .font(.footnote)
                Text("Storage: \(inspection.detectedStorageProfile?.rawValue ?? "unknown")")
                    .font(.footnote)
            }

            if let features = lastFeaturesResult {
                Text("IDEA -> FEATURES: \(statusText(for: features.result))")
                Text("Candidates: \(features.proposedFeatures.count)")
                    .font(.footnote)
                if !features.promptText.isEmpty {
                    Text(features.promptText)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }

            if let prd = lastPRDFromFeaturesResult {
                Text("FEATURES -> PRD: \(statusText(for: prd.result))")
                Text("Features in PRD prompt: \(prd.featuresCount)")
                    .font(.footnote)
                if !prd.promptText.isEmpty {
                    Text(prd.promptText)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }

            if let bdd = lastBDDFromPRDResult {
                Text("PRD -> BDD: \(statusText(for: bdd.result))")
                Text("PRD length: \(bdd.prdLength)")
                    .font(.footnote)
                if !bdd.promptText.isEmpty {
                    Text(bdd.promptText)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }

            if let tests = lastTestsFromBDDResult {
                Text("BDD -> TESTS: \(statusText(for: tests.result))")
                Text("BDD length: \(tests.bddLength)")
                    .font(.footnote)
                if !tests.promptText.isEmpty {
                    Text(tests.promptText)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }

            if let implementation = lastImplementationFromTestsResult {
                Text("TESTS -> IMPLEMENTATION: \(statusText(for: implementation.result))")
                Text("Tests length: \(implementation.testsLength)")
                    .font(.footnote)
                if !implementation.promptText.isEmpty {
                    Text(implementation.promptText)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }

            if let validation = lastValidationFromImplementationResult {
                Text("IMPLEMENTATION -> VALIDATION: \(statusText(for: validation.result))")
                Text("Implementation length: \(validation.implementationLength)")
                    .font(.footnote)
                if !validation.promptText.isEmpty {
                    Text(validation.promptText)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }
        }
    }

    func statusText(for result: RegistryOperationResult) -> String {
        switch result {
        case .success:
            return "success"
        case let .failure(reason):
            return "failure (\(reason.message))"
        }
    }
}

#Preview {
    ContentView()
}
