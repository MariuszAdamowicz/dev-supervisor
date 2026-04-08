import SwiftUI

struct ContentView: View {
    @State var projects: [WorkspaceProject] = []
    @State var ideas: [IdeaRecord] = []
    @State var selectedProjectID: String?
    @State var selectedIdeaID: String?
    @State var activeInspection: ProjectInspectionResult?
    @State var workbenchState = FeatureWorkbenchState()
    @State var workspaceNotice: WorkspaceNotice?

    @State var showCreateProjectSheet = false
    @State var showAttachProjectSheet = false
    @State var showCreateIdeaSheet = false

    @State var createProjectDraft = CreateProjectDraft()
    @State var attachProjectDraft = AttachProjectDraft()
    @State var newIdeaDraft = NewIdeaDraft()

    let bootstrapService: any ProjectBootstrapContract = ProjectBootstrapFileSystem()
    let fileAIProjectRegistryService: any ProjectRegistryContract = ProjectRegistryPersistentFileSystem(storageProfile: .fileAI)
    let sqlbaseProjectRegistryService: any ProjectRegistryContract = ProjectRegistryPersistentFileSystem(storageProfile: .sqlbase)
    let fileAIIdeaRegistryService: IdeaRegistryContract = IdeaRegistryPersistentFileSystem(storageProfile: .fileAI)
    let sqlbaseIdeaRegistryService: IdeaRegistryContract = IdeaRegistryPersistentFileSystem(storageProfile: .sqlbase)
    let gatePersistenceService: any GatePromptPersistenceContract = GatePromptPersistenceFileSystem()
    let ideaToFeaturesService: any IdeaToFeaturesFlowContract = IdeaToFeaturesFlowInMemory()
    let featuresToPRDService: any FeaturesToPRDFlowContract = FeaturesToPRDFlowInMemory()
    let prdToBDDService: any PRDToBDDFlowContract = PRDToBDDFlowInMemory()
    let bddToTestsService: any BDDToTestsFlowContract = BDDToTestsFlowInMemory()
    let testsToImplementationService: any TestsToImplementationFlowContract = TestsToImplementationFlowInMemory()
    let implementationToValidationService: any ImplementationToValidationFlowContract = ImplementationToValidationFlowInMemory()
    let sqlProjectStore = SQLProjectStore()

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 260, ideal: 300)
        } detail: {
            detailPane
        }
        .frame(minWidth: 1100, minHeight: 720)
        .toolbar {
            ToolbarItemGroup {
                Button("Nowy projekt") {
                    prepareCreateProjectSheet()
                }
                Button("Podłącz projekt") {
                    attachProjectDraft = AttachProjectDraft()
                    showAttachProjectSheet = true
                }
                Button("Nowa idea") {
                    newIdeaDraft = NewIdeaDraft()
                    showCreateIdeaSheet = true
                }
                .disabled(selectedProject == nil)
                Button("Odśwież") {
                    refreshWorkspace(retainingSelection: true)
                }
            }
        }
        .sheet(isPresented: $showCreateProjectSheet) {
            createProjectSheet
        }
        .sheet(isPresented: $showAttachProjectSheet) {
            attachProjectSheet
        }
        .sheet(isPresented: $showCreateIdeaSheet) {
            createIdeaSheet
        }
        .onAppear {
            if createProjectDraft.rootPath.isEmpty {
                createProjectDraft.rootPath = defaultProjectsRootPath()
            }
            refreshWorkspace(retainingSelection: true)
        }
    }
}

extension ContentView {
    var selectedProject: WorkspaceProject? {
        projects.first { $0.id == selectedProjectID }
    }

    var selectedIdea: IdeaRecord? {
        ideas.first { $0.id.rawValue == selectedIdeaID }
    }

    var sidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DevSupervisor")
                        .font(.title.bold())
                    Text("Jedna funkcja od idei do walidacji.")
                        .foregroundStyle(.secondary)
                }

                if let notice = workspaceNotice {
                    noticeBanner(notice)
                }

                sidebarSection(title: "Projekty") {
                    if projects.isEmpty {
                        Text("Brak projektów w registry. Zacznij od utworzenia albo podłączenia katalogu.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(projects, id: \.id) { project in
                            projectRow(project)
                        }
                    }
                }

                if let project = selectedProject {
                    sidebarSection(title: "Idee") {
                        if ideas.isEmpty {
                            Text("Wybrany projekt nie ma jeszcze idei.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(ideas, id: \.id.rawValue) { idea in
                                ideaRow(idea, in: project)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(nsColor: .underPageBackgroundColor))
    }

    var detailPane: some View {
        Group {
            if let project = selectedProject {
                if let idea = selectedIdea {
                    FeatureWorkbenchView(
                        project: project,
                        idea: idea,
                        inspection: activeInspection,
                        stackRulesAvailable: stackRulesAvailable(for: project),
                        state: $workbenchState,
                        onSelectStep: { workbenchState.selectedStep = $0 },
                        onGenerateFeatures: generateFeatureSet,
                        onApproveFeatures: approveFeatureSet,
                        onGeneratePRD: generatePRDPrompt,
                        onApprovePRD: approvePRD,
                        onGenerateBDD: generateBDDPrompt,
                        onApproveBDD: approveBDD,
                        onGenerateTests: generateTestsPrompt,
                        onApproveTests: approveTests,
                        onGenerateImplementation: generateImplementationPrompt,
                        onApproveImplementation: approveImplementation,
                        onGenerateValidation: generateValidationPrompt,
                        onApproveValidation: approveValidation
                    )
                } else {
                    emptyState(
                        title: project.record.name,
                        message: "Projekt jest gotowy w registry. Dodaj jedną ideę albo wybierz istniejącą i dopiero wtedy uruchom workbench funkcji."
                    )
                }
            } else {
                emptyState(
                    title: "Wybierz projekt",
                    message: "Ta wersja aplikacji prowadzi jeden czysty slice: wybór projektu, wybór idei, a potem `Idea -> Feature -> PRD -> BDD -> testy -> implementacja -> walidacja`."
                )
            }
        }
    }

    func sidebarSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    func projectRow(_ project: WorkspaceProject) -> some View {
        Button {
            selectProject(project)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(project.record.name)
                        .font(.headline)
                    Spacer()
                    Text(project.storageProfile.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(project.record.id.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(project.record.localPath)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(project.id == selectedProjectID ? Color.accentColor.opacity(0.16) : Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    func ideaRow(_ idea: IdeaRecord, in project: WorkspaceProject) -> some View {
        Button {
            selectIdea(idea, in: project)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.subheadline.weight(.semibold))
                HStack {
                    Text(idea.id.rawValue)
                    Text(idea.status.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                if let description = idea.description, !description.isEmpty {
                    Text(description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(idea.id.rawValue == selectedIdeaID ? Color.accentColor.opacity(0.16) : Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    func emptyState(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.largeTitle.bold())
            Text(message)
                .font(.title3)
                .foregroundStyle(.secondary)
            if let project = selectedProject {
                projectSummary(project)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(32)
    }

    func noticeBanner(_ notice: WorkspaceNotice) -> some View {
        Text(notice.message)
            .font(.footnote)
            .foregroundStyle(notice.isError ? Color.red : Color.secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background((notice.isError ? Color.red : Color.secondary).opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    func projectSummary(_ project: WorkspaceProject) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.record.name)
                .font(.headline)
            Text(project.record.localPath)
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let inspection = activeInspection {
                Text("Baseline: \(inspection.productGatePassed ? "gotowy" : "niekompletny")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if !inspection.missingProductArtifacts.isEmpty {
                    Text("Brakuje: \(inspection.missingProductArtifacts.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    var createProjectSheet: some View {
        NavigationStack {
            Form {
                TextField("Nazwa projektu", text: $createProjectDraft.name)
                TextField("Katalog nadrzędny", text: $createProjectDraft.rootPath)
                Picker("Storage", selection: $createProjectDraft.storageProfile) {
                    ForEach(StorageProfile.allCases, id: \.self) { profile in
                        Text(profile.rawValue).tag(profile)
                    }
                }
                .pickerStyle(.segmented)
                Toggle("Zainicjalizuj repozytorium git", isOn: $createProjectDraft.initializeGitRepository)
            }
            .formStyle(.grouped)
            .navigationTitle("Nowy projekt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        showCreateProjectSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Utwórz") {
                        createProject()
                    }
                }
            }
        }
        .frame(minWidth: 420, minHeight: 260)
    }

    var attachProjectSheet: some View {
        NavigationStack {
            Form {
                TextField("Ścieżka do projektu", text: $attachProjectDraft.path)
            }
            .formStyle(.grouped)
            .navigationTitle("Podłącz projekt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        showAttachProjectSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Podłącz") {
                        attachProject()
                    }
                }
            }
        }
        .frame(minWidth: 420, minHeight: 200)
    }

    var createIdeaSheet: some View {
        NavigationStack {
            Form {
                TextField("Tytuł idei", text: $newIdeaDraft.title)
                TextField("Opis idei", text: $newIdeaDraft.description, axis: .vertical)
            }
            .formStyle(.grouped)
            .navigationTitle("Nowa idea")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        showCreateIdeaSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dodaj") {
                        createIdea()
                    }
                    .disabled(selectedProject == nil)
                }
            }
        }
        .frame(minWidth: 420, minHeight: 220)
    }
}

struct WorkspaceNotice: Equatable {
    let message: String
    let isError: Bool
}

struct CreateProjectDraft: Equatable {
    var name = ""
    var rootPath = ""
    var storageProfile: StorageProfile = .sqlbase
    var initializeGitRepository = true
}

struct AttachProjectDraft: Equatable {
    var path = ""
}

struct NewIdeaDraft: Equatable {
    var title = ""
    var description = ""
}

#Preview {
    ContentView()
}
