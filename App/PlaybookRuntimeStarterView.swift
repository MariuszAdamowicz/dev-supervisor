import SwiftUI

struct PlaybookRuntimeStarterView: View {
    @State private var projectName = "Starter DS"
    @State private var projectRootPath = ""
    @State private var projectDescription = "DevSupervisor uruchamia nowy projekt, baseline i pierwsza idee bez silent transitions."
    @State private var stack = "macos-swiftui"
    @State private var architecture = "modular-monolith"
    @State private var language = "pl"
    @State private var executionStyle = "iterative-tdd"
    @State private var storageProfile: StorageProfile = .fileAI
    @State private var createRemoteRepository = true
    @State private var baselineDecision: PlaybookGateDecision = .approve
    @State private var baselineReason = "baseline kompletny i niesprzeczny"
    @State private var ideaTitle = "Uruchomienie projektu z UI"
    @State private var ideaDescription = "Operator tworzy projekt, baseline i pochodne OP w jednym nadzorowanym flow."
    @State private var ideaDecision: PlaybookGateDecision = .approve
    @State private var ideaReason = "idea gotowa do konwersji"
    @State private var lastNewProjectResult: PlaybookNewProjectResult?
    @State private var lastAddIdeaResult: PlaybookAddIdeaResult?
    @State private var runtimeSummary: PlaybookRuntimeSummary?

    private let runtimeService: PlaybookRuntimeContract = PlaybookRuntimeFileSystem()

    private let stacks = [
        "macos-swiftui",
        "kotlin-android",
        "flutter-dart",
        "react-node-postgres",
        "python-fastapi-react",
    ]
    private let architectures = [
        "modular-monolith",
        "clean-architecture",
        "hexagonal",
        "layered-monolith",
    ]
    private let languages = ["pl", "en"]
    private let executionStyles = ["iterative-tdd", "batch-feature", "hybrid"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Playbook Runtime Starter")
                .font(.title2.bold())
            Text("Kanoniczny flow `new_project -> add_idea` z baseline, GateDecision i audytem `.ai/runtime/v1`.")
                .foregroundStyle(.secondary)

            Group {
                TextField("Project name", text: $projectName)
                    .textFieldStyle(.roundedBorder)
                TextField("Project path", text: $projectRootPath)
                    .textFieldStyle(.roundedBorder)
                TextEditor(text: $projectDescription)
                    .font(.footnote)
                    .frame(minHeight: 88)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                    )
            }

            Group {
                Picker("Stack", selection: $stack) {
                    ForEach(stacks, id: \.self) { value in
                        Text(value).tag(value)
                    }
                }
                Picker("Architecture", selection: $architecture) {
                    ForEach(architectures, id: \.self) { value in
                        Text(value).tag(value)
                    }
                }
                Picker("Language", selection: $language) {
                    ForEach(languages, id: \.self) { value in
                        Text(value).tag(value)
                    }
                }
                Picker("Execution style", selection: $executionStyle) {
                    ForEach(executionStyles, id: \.self) { value in
                        Text(value).tag(value)
                    }
                }
                Picker("Storage", selection: $storageProfile) {
                    Text("file-ai").tag(StorageProfile.fileAI)
                    Text("sqlbase").tag(StorageProfile.sqlbase)
                }
                Toggle("Create or connect remote GitHub repository", isOn: $createRemoteRepository)
            }

            gateSection(
                title: "Baseline gate",
                decision: $baselineDecision,
                reason: $baselineReason
            )

            HStack(spacing: 12) {
                Button("Run New Project") {
                    runNewProject()
                }
                .buttonStyle(.borderedProminent)

                Button("Run End-to-End Starter") {
                    runNewProject()
                    guard lastNewProjectResult?.result.isSuccess == true else {
                        return
                    }
                    addIdea()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("First Idea")
                    .font(.headline)
                TextField("Idea title", text: $ideaTitle)
                    .textFieldStyle(.roundedBorder)
                TextField("Idea description", text: $ideaDescription)
                    .textFieldStyle(.roundedBorder)

                gateSection(
                    title: "Idea convert gate",
                    decision: $ideaDecision,
                    reason: $ideaReason
                )

                Button("Add First Idea") {
                    addIdea()
                }
                .buttonStyle(.borderedProminent)
                .disabled(runtimeSummary?.projectState != "active")
            }

            if let newProject = lastNewProjectResult {
                statusBlock(
                    title: "New Project",
                    result: newProject.result,
                    details: [
                        "project_path": newProject.projectPath ?? "n/a",
                        "project_state": newProject.projectState ?? "n/a",
                        "remote_url": newProject.remoteURL ?? "n/a",
                        "playbook_instance": newProject.playbookInstancePath ?? "n/a",
                        "envelope": newProject.decisionEnvelopePath ?? "n/a",
                    ]
                )
            }

            if let addIdea = lastAddIdeaResult {
                statusBlock(
                    title: "Add Idea",
                    result: addIdea.result,
                    details: [
                        "idea_id": addIdea.ideaID ?? "n/a",
                        "idea_state": addIdea.ideaState ?? "n/a",
                        "envelope": addIdea.decisionEnvelopePath ?? "n/a",
                    ]
                )

                if !addIdea.derivedOps.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Derived OP")
                            .font(.headline)
                        ForEach(addIdea.derivedOps) { op in
                            Text("\(op.opType) • \(op.opID) • \(op.state)")
                                .font(.footnote.monospaced())
                        }
                    }
                }
            }

            if let runtimeSummary {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Runtime Summary")
                        .font(.headline)
                    Text("project_state: \(runtimeSummary.projectState ?? "n/a")")
                        .font(.footnote)
                    Text("remote_url: \(runtimeSummary.remoteURL ?? "n/a")")
                        .font(.footnote)
                    Text("process_events: \(runtimeSummary.processEventCount) | gate_decisions: \(runtimeSummary.gateDecisionCount)")
                        .font(.footnote)
                    Text("last_event_id: \(runtimeSummary.lastEventID ?? "n/a")")
                        .font(.footnote)
                    ForEach(runtimeSummary.allOps) { op in
                        Text("\(op.opType) • \(op.opID) • \(op.state)")
                            .font(.footnote.monospaced())
                    }
                }
            }
        }
        .onAppear {
            if projectRootPath.isEmpty {
                projectRootPath = defaultProjectPath()
            }
        }
    }
}

private extension PlaybookRuntimeStarterView {
    func runNewProject() {
        let result = runtimeService.runNewProject(
            PlaybookNewProjectRequest(
                projectName: projectName,
                projectRootPath: projectRootPath,
                profileSelection: PlaybookProfileSelection(
                    stack: stack,
                    architecture: architecture,
                    language: language,
                    executionStyle: executionStyle,
                    storage: storageProfile
                ),
                projectDescription: projectDescription,
                baselineGate: PlaybookGateInput(
                    decision: baselineDecision,
                    reason: baselineReason
                ),
                createRemoteRepository: createRemoteRepository
            )
        )

        lastNewProjectResult = result
        lastAddIdeaResult = nil
        if let projectPath = result.projectPath {
            runtimeSummary = runtimeService.summarizeRuntime(at: projectPath)
        }
    }

    func addIdea() {
        guard let projectPath = lastNewProjectResult?.projectPath ?? runtimeSummary?.projectPath else {
            lastAddIdeaResult = PlaybookAddIdeaResult(
                result: .failure(.init(message: "Run New Project successfully before adding the first idea.")),
                projectPath: projectRootPath,
                ideaID: nil,
                ideaState: nil,
                decisionEnvelopePath: nil,
                derivedOps: [],
                createdArtifacts: []
            )
            return
        }

        let result = runtimeService.addIdea(
            PlaybookAddIdeaRequest(
                projectRootPath: projectPath,
                ideaTitle: ideaTitle,
                ideaDescription: ideaDescription,
                convertGate: PlaybookGateInput(
                    decision: ideaDecision,
                    reason: ideaReason
                )
            )
        )

        lastAddIdeaResult = result
        runtimeSummary = runtimeService.summarizeRuntime(at: projectPath)
    }

    func gateSection(
        title: String,
        decision: Binding<PlaybookGateDecision>,
        reason: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Picker(title, selection: decision) {
                ForEach(PlaybookGateDecision.allCases) { value in
                    Text(value.label).tag(value)
                }
            }
            .pickerStyle(.segmented)
            TextField("Reason", text: reason)
                .textFieldStyle(.roundedBorder)
        }
    }

    func statusBlock(title: String, result: RegistryOperationResult, details: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title): \(statusText(for: result))")
            ForEach(details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                Text("\(key): \(value)")
                    .font(.footnote)
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

    func defaultProjectPath() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Projects/\(slugify(projectName))"
    }

    func slugify(_ value: String) -> String {
        let lowered = value.lowercased()
        let replaced = lowered.replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
        return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
