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
    @State private var lastFeaturesResult: FeatureSetPromptGenerationResult?

    private let bootstrapService: any ProjectBootstrapContract = ProjectBootstrapFileSystem()
    private let ideaToFeaturesService: any IdeaToFeaturesFlowContract = IdeaToFeaturesFlowInMemory()

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

    private var statusSection: some View {
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
        }
    }

    private func statusText(for result: RegistryOperationResult) -> String {
        switch result {
        case .success:
            return "success"
        case let .failure(reason):
            return "failure (\(reason.message))"
        }
    }

    private func defaultProjectsRootPath() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Projects"
    }
}

#Preview {
    ContentView()
}
