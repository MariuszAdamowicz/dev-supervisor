import SwiftUI

struct ContentView: View {
    @State private var projectName = ""
    @State private var projectsRootPath = ""
    @State private var selectedStorageProfile: StorageProfile = .fileAI
    @State private var initializeGitRepository = true

    @State private var inspectPath = ""
    @State private var activeProjectPathForPersistence = ""
    @State private var activeStorageProfileForPersistence: StorageProfile = .fileAI

    @State private var lastBootstrapResult: ProjectBootstrapResult?
    @State private var lastInspectionResult: ProjectInspectionResult?
    @State private var flowProjectID = "P-1"
    @State private var flowIdeaID = "I-1"
    @State private var flowIdeaTitle = ""
    @State private var flowIdeaStatus: IdeaStatus = .selected
    @State private var newIdeaTitle = ""
    @State private var newIdeaDescription = ""
    @State private var ideasForActiveProject: [IdeaRecord] = []
    @State private var lastIdeaCreationResult: IdeaCreationResult?
    @State private var lastIdeaListResult: IdeaListResult?
    @State private var lastIdeaSelectionResult: RegistryOperationResult?
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
    @State private var lastPersistenceResult: GatePromptPersistenceResult?
    @State private var lastProjectRegistrationResult: ProjectRegistrationResult?
    @State private var lastArtifactSyncResult: ArtifactSyncResult?

    private let bootstrapService: any ProjectBootstrapContract = ProjectBootstrapFileSystem()
    private let fileAIProjectRegistryService: any ProjectRegistryContract =
        ProjectRegistryPersistentFileSystem(storageProfile: .fileAI)
    private let sqlbaseProjectRegistryService: any ProjectRegistryContract =
        ProjectRegistryPersistentFileSystem(storageProfile: .sqlbase)
    private let fileAIIdeaRegistryService: IdeaRegistryContract =
        IdeaRegistryPersistentFileSystem(storageProfile: .fileAI)
    private let sqlbaseIdeaRegistryService: IdeaRegistryContract =
        IdeaRegistryPersistentFileSystem(storageProfile: .sqlbase)
    private let artifactSyncService: any ArtifactSyncContract = ArtifactSyncFileSystem()
    private let ideaToFeaturesService: any IdeaToFeaturesFlowContract = IdeaToFeaturesFlowInMemory()
    private let featuresToPRDService: any FeaturesToPRDFlowContract = FeaturesToPRDFlowInMemory()
    private let prdToBDDService: any PRDToBDDFlowContract = PRDToBDDFlowInMemory()
    private let bddToTestsService: any BDDToTestsFlowContract = BDDToTestsFlowInMemory()
    private let testsToImplementationService: any TestsToImplementationFlowContract = TestsToImplementationFlowInMemory()
    private let implementationToValidationService: any ImplementationToValidationFlowContract = ImplementationToValidationFlowInMemory()
    private let gatePersistenceService: any GatePromptPersistenceContract = GatePromptPersistenceFileSystem()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Dev Supervisor")
                    .font(.largeTitle.bold())
                Text("Deterministyczny bootstrap i inspekcja projektu")
                    .foregroundStyle(.secondary)

                newProjectSection
                Divider()
                ideaRegistrySection
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
            refreshIdeasForActiveProject()
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
                let result = bootstrapService.bootstrapProject(input)
                lastBootstrapResult = result
                if result.result.isSuccess, let path = result.projectPath {
                    activeProjectPathForPersistence = path
                    activeStorageProfileForPersistence = selectedStorageProfile
                    inspectPath = path
                    lastInspectionResult = bootstrapService.inspectProject(at: path)
                    autoRegisterBootstrappedProject(at: path, profile: selectedStorageProfile)
                }
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
                guard let inspection = lastInspectionResult, inspection.result.isSuccess else {
                    lastFeaturesResult = FeatureSetPromptGenerationResult(
                        result: .failure(.init(message: "Inspect project and pass Product Gate before IDEA -> FEATURES.")),
                        promptText: "",
                        promptFingerprint: "",
                        includesMinimalContext: false,
                        ideaID: nil,
                        projectID: nil,
                        proposedFeatures: []
                    )
                    return
                }

                guard inspection.productGatePassed else {
                    let missing = inspection.missingProductArtifacts.joined(separator: ", ")
                    lastFeaturesResult = FeatureSetPromptGenerationResult(
                        result: .failure(.init(message: "Product Gate failed. Missing: \(missing).")),
                        promptText: "",
                        promptFingerprint: "",
                        includesMinimalContext: false,
                        ideaID: nil,
                        projectID: nil,
                        proposedFeatures: []
                    )
                    return
                }

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

                let result = ideaToFeaturesService.generateFeaturesPrompt(for: ideaID)
                lastFeaturesResult = result
                persistPromptIfPossible(
                    operation: "IDEA -> FEATURES",
                    gateResult: result.result,
                    promptText: result.promptText,
                    ideaID: result.ideaID,
                    projectID: result.projectID
                )
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

                let result = featuresToPRDService.generatePRDPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    features: featuresResult.proposedFeatures
                )
                lastPRDFromFeaturesResult = result
                persistPromptIfPossible(
                    operation: "FEATURES -> PRD",
                    gateResult: result.result,
                    promptText: result.promptText,
                    ideaID: result.ideaID,
                    projectID: result.projectID
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

                let result = prdToBDDService.generateBDDPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    prdDocument: finalPRDDocument
                )
                lastBDDFromPRDResult = result
                persistPromptIfPossible(
                    operation: "PRD -> BDD",
                    gateResult: result.result,
                    promptText: result.promptText,
                    ideaID: result.ideaID,
                    projectID: result.projectID
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

                let result = bddToTestsService.generateTestsPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    bddDocument: finalBDDDoc
                )
                lastTestsFromBDDResult = result
                persistPromptIfPossible(
                    operation: "BDD -> TESTS",
                    gateResult: result.result,
                    promptText: result.promptText,
                    ideaID: result.ideaID,
                    projectID: result.projectID
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private extension ContentView {
    func defaultProjectsRootPath() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Projects"
    }

    var inspectProjectSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Otwórz istniejący projekt")
                .font(.title2.bold())

            TextField("Ścieżka do projektu", text: $inspectPath)
                .textFieldStyle(.roundedBorder)

            Button("Inspect project") {
                let result = bootstrapService.inspectProject(at: inspectPath)
                lastInspectionResult = result
                if result.result.isSuccess {
                    activeProjectPathForPersistence = result.projectPath
                    if let storage = result.detectedStorageProfile {
                        activeStorageProfileForPersistence = storage
                    }
                }
            }
            .buttonStyle(.bordered)

            Text("sqlbase sync: DB <-> .ai")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Export .ai -> sqlbase") {
                    runArtifactSync(.exportAIToSQLBase)
                }
                .buttonStyle(.bordered)
                .disabled(!isSQLBaseProfileActive)

                Button("Import sqlbase -> .ai") {
                    runArtifactSync(.importSQLBaseToAI)
                }
                .buttonStyle(.bordered)
                .disabled(!isSQLBaseProfileActive)
            }
        }
    }

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

                let result = testsToImplementationService.generateImplementationPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    testsDocument: finalTestsDoc
                )
                lastImplementationFromTestsResult = result
                persistPromptIfPossible(
                    operation: "TESTS -> IMPLEMENTATION",
                    gateResult: result.result,
                    promptText: result.promptText,
                    ideaID: result.ideaID,
                    projectID: result.projectID
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

                let result = implementationToValidationService.generateValidationPrompt(
                    for: ideaID,
                    ideaTitle: ideaTitle,
                    implementationDocument: finalImplementationDoc
                )
                lastValidationFromImplementationResult = result
                persistPromptIfPossible(
                    operation: "IMPLEMENTATION -> VALIDATION",
                    gateResult: result.result,
                    promptText: result.promptText,
                    ideaID: result.ideaID,
                    projectID: result.projectID
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
                Text("Product Gate: \(inspection.productGatePassed ? "pass" : "fail")")
                    .font(.footnote)
                Text("overview: \(inspection.hasOverview ? "yes" : "no") | constraints: \(inspection.hasConstraints ? "yes" : "no") | glossary: \(inspection.hasGlossary ? "yes" : "no")")
                    .font(.footnote)
                if !inspection.missingProductArtifacts.isEmpty {
                    Text("Missing artifacts: \(inspection.missingProductArtifacts.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
                Text("Storage: \(inspection.detectedStorageProfile?.rawValue ?? "unknown")")
                    .font(.footnote)
            }

            if let registration = lastProjectRegistrationResult {
                Text("Registry: \(statusText(for: registration.result))")
                if let createdProjectID = registration.createdProjectID {
                    Text("Registered project ID: \(createdProjectID.rawValue)")
                        .font(.footnote)
                }
                Text("Registered projects count: \(activeProjectRegistryService.listProjects().count)")
                    .font(.footnote)
            }

            if let artifactSync = lastArtifactSyncResult {
                Text("Artifact Sync: \(statusText(for: artifactSync.result))")
                Text("Synchronized files: \(artifactSync.synchronizedFiles.count)")
                    .font(.footnote)
            }

            if let ideaCreation = lastIdeaCreationResult {
                Text("Idea create: \(statusText(for: ideaCreation.result))")
                if let createdIdeaID = ideaCreation.createdIdeaID {
                    Text("Created idea ID: \(createdIdeaID.rawValue)")
                        .font(.footnote)
                }
            }

            if let ideaList = lastIdeaListResult {
                Text("Idea list: \(statusText(for: ideaList.result))")
                Text("Ideas in active project: \(ideaList.ideas.count)")
                    .font(.footnote)
            }

            if let ideaSelection = lastIdeaSelectionResult {
                Text("Idea selection: \(statusText(for: ideaSelection))")
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

            if let persistence = lastPersistenceResult {
                Text("Persistence: \(statusText(for: persistence.result))")
                if let persistedPath = persistence.persistedPath {
                    Text("Saved prompt: \(persistedPath)")
                        .font(.footnote)
                }
            }
        }
    }

    func persistPromptIfPossible(
        operation: String,
        gateResult: RegistryOperationResult,
        promptText: String,
        ideaID: IdeaID?,
        projectID: ProjectID?
    ) {
        guard gateResult.isSuccess else {
            return
        }

        let activePath = activeProjectPathForPersistence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !activePath.isEmpty else {
            lastPersistenceResult = GatePromptPersistenceResult(
                result: .failure(.init(message: "Persistence skipped: active project path is not set.")),
                persistedPath: nil
            )
            return
        }

        let request = GatePromptPersistenceRequest(
            projectPath: activePath,
            storageProfile: activeStorageProfileForPersistence,
            operation: operation,
            ideaID: ideaID,
            projectID: projectID,
            promptText: promptText
        )
        lastPersistenceResult = gatePersistenceService.persistPrompt(request)
    }

    func statusText(for result: RegistryOperationResult) -> String {
        switch result {
        case .success:
            return "success"
        case let .failure(reason):
            return "failure (\(reason.message))"
        }
    }

    func autoRegisterBootstrappedProject(at projectPath: String, profile: StorageProfile) {
        let normalizedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        let registrationName: String
        if normalizedName.isEmpty {
            registrationName = URL(fileURLWithPath: projectPath).lastPathComponent
        } else {
            registrationName = normalizedName
        }

        let registryService = projectRegistryService(for: profile)
        let registration = registryService.registerProject(
            name: registrationName,
            localPath: projectPath
        )
        lastProjectRegistrationResult = registration

        if let createdProjectID = registration.createdProjectID {
            _ = registryService.selectActiveWorkingProject(id: createdProjectID)
            flowProjectID = createdProjectID.rawValue
            refreshIdeasForActiveProject()
        }
    }

    func runArtifactSync(_ direction: ArtifactSyncDirection) {
        let activePath = activeProjectPathForPersistence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !activePath.isEmpty else {
            lastArtifactSyncResult = ArtifactSyncResult(
                result: .failure(.init(message: "Artifact sync skipped: active project path is not set.")),
                synchronizedFiles: []
            )
            return
        }

        let request = ArtifactSyncRequest(
            projectPath: activePath,
            storageProfile: activeStorageProfileForPersistence,
            direction: direction
        )
        lastArtifactSyncResult = artifactSyncService.synchronize(request)
    }

    var isSQLBaseProfileActive: Bool {
        activeStorageProfileForPersistence == .sqlbase
    }

    var activeProjectRegistryService: any ProjectRegistryContract {
        projectRegistryService(for: activeStorageProfileForPersistence)
    }

    func projectRegistryService(for profile: StorageProfile) -> any ProjectRegistryContract {
        switch profile {
        case .fileAI:
            return fileAIProjectRegistryService
        case .sqlbase:
            return sqlbaseProjectRegistryService
        }
    }

    var activeIdeaRegistryService: IdeaRegistryContract {
        ideaRegistryService(for: activeStorageProfileForPersistence)
    }

    func ideaRegistryService(for profile: StorageProfile) -> IdeaRegistryContract {
        switch profile {
        case .fileAI:
            return fileAIIdeaRegistryService
        case .sqlbase:
            return sqlbaseIdeaRegistryService
        }
    }
}

private extension ContentView {
    var ideaRegistrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Idea Registry")
                .font(.title2.bold())

            Text("Operator tworzy i wybiera ideę. Wybrana idea zasila kolejne gate'y.")
                .foregroundStyle(.secondary)

            Text("Active project for ideas: \(flowProjectID)")
                .font(.footnote)

            TextField("Nowa idea — tytuł", text: $newIdeaTitle)
                .textFieldStyle(.roundedBorder)

            TextField("Nowa idea — opis (opcjonalnie)", text: $newIdeaDescription)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 12) {
                Button("Create idea") {
                    let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
                    activeIdeaRegistryService.selectActiveProject(id: projectID)

                    let rawDescription = newIdeaDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                    let description = rawDescription.isEmpty ? nil : rawDescription
                    let creation = activeIdeaRegistryService.createIdea(
                        title: newIdeaTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: description
                    )

                    lastIdeaCreationResult = creation
                    if let createdIdeaID = creation.createdIdeaID,
                       let createdIdea = activeIdeaRegistryService.idea(by: createdIdeaID)
                    {
                        applyIdeaToFlow(createdIdea)
                        newIdeaTitle = ""
                        newIdeaDescription = ""
                    }
                    refreshIdeasForActiveProject()
                }
                .buttonStyle(.borderedProminent)

                Button("Refresh ideas") {
                    refreshIdeasForActiveProject()
                }
                .buttonStyle(.bordered)
            }

            if ideasForActiveProject.isEmpty {
                Text("Brak idei dla aktywnego projektu.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(ideasForActiveProject, id: \.id.rawValue) { idea in
                    HStack(spacing: 12) {
                        Text("\(idea.id.rawValue) • \(idea.status.rawValue) • \(idea.title)")
                            .font(.footnote)
                        Spacer()
                        Button("Use in flow") {
                            applyIdeaToFlow(idea)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    func refreshIdeasForActiveProject() {
        let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
        activeIdeaRegistryService.selectActiveProject(id: projectID)
        let list = activeIdeaRegistryService.listIdeasForActiveProject()
        lastIdeaListResult = list
        ideasForActiveProject = list.ideas
    }

    func applyIdeaToFlow(_ idea: IdeaRecord) {
        let projectID = ProjectID(rawValue: flowProjectID.trimmingCharacters(in: .whitespacesAndNewlines))
        activeIdeaRegistryService.selectActiveProject(id: projectID)

        let selectionResult = activeIdeaRegistryService.changeIdeaStatus(id: idea.id, status: .selected)
        lastIdeaSelectionResult = selectionResult

        flowIdeaID = idea.id.rawValue
        flowIdeaTitle = idea.title
        flowIdeaStatus = .selected
        refreshIdeasForActiveProject()
    }
}

#Preview {
    ContentView()
}
