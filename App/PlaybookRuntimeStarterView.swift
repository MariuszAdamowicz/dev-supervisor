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
    @State private var showAuditDetails = false

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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroPanel
                progressPanel
                newProjectPanel

                if let runtimeSummary {
                    baselineReadinessPanel(runtimeSummary)
                }

                ideaPanel

                if let newProject = lastNewProjectResult {
                    outcomePanel(
                        title: "Nowy projekt",
                        subtitle: "Stan po uruchomieniu entrypointu `new_project`.",
                        result: newProject.result,
                        details: [
                            ("Stan projektu", newProject.projectState ?? "n/a"),
                            ("Repozytorium zdalne", newProject.remoteURL ?? "niepodlaczone"),
                            ("Instancja playbooka", newProject.playbookInstancePath ?? "n/a"),
                            ("Decision envelope", newProject.decisionEnvelopePath ?? "n/a"),
                        ]
                    )
                }

                if let addIdea = lastAddIdeaResult {
                    outcomePanel(
                        title: "Pierwsza idea",
                        subtitle: "Stan po uruchomieniu entrypointu `add_idea`.",
                        result: addIdea.result,
                        details: [
                            ("ID idei", addIdea.ideaID ?? "n/a"),
                            ("Stan idei", addIdea.ideaState ?? "n/a"),
                            ("Decision envelope", addIdea.decisionEnvelopePath ?? "n/a"),
                        ]
                    )

                    if !addIdea.derivedOps.isEmpty {
                        card {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Wygenerowane pochodne OP")
                                    .font(.system(.headline, design: .rounded))
                                FlowLayout(spacing: 10) {
                                    ForEach(addIdea.derivedOps) { op in
                                        chip(title: op.opType, subtitle: "\(op.opID) • \(op.state)")
                                    }
                                }
                            }
                        }
                    }
                }

                if let runtimeSummary {
                    auditPanel(runtimeSummary)
                }
            }
            .padding(28)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.93),
                    Color(red: 0.98, green: 0.95, blue: 0.90),
                    Color.white,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            if projectRootPath.isEmpty {
                projectRootPath = defaultProjectPath()
            }
        }
    }
}

private extension PlaybookRuntimeStarterView {
    var heroPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start projektu wg playbooka")
                .font(.system(.title, design: .rounded).weight(.bold))
            Text("Cel operatora: uruchomic nowy projekt, przygotowac baseline i zapisac pierwsza idee bez wystawiania mechaniki runtime jako glownego UI.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                badge(text: "Task-first UI", color: Color(red: 0.12, green: 0.54, blue: 0.53))
                badge(text: "Audit w szczegolach", color: Color(red: 0.86, green: 0.48, blue: 0.16))
                badge(text: "No silent transitions", color: Color(red: 0.24, green: 0.43, blue: 0.78))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.24, blue: 0.34),
                            Color(red: 0.16, green: 0.49, blue: 0.47),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .foregroundStyle(.white)
    }

    var progressPanel: some View {
        card {
            VStack(alignment: .leading, spacing: 16) {
                Text("Przebieg operatora")
                    .font(.system(.headline, design: .rounded))

                HStack(spacing: 12) {
                    progressStep(
                        title: "1. Konfiguracja",
                        detail: lastNewProjectResult == nil ? "formularz" : (runtimeSummary?.projectState ?? "gotowe"),
                        isDone: lastNewProjectResult?.result.isSuccess == true
                    )
                    progressStep(
                        title: "2. Baseline",
                        detail: runtimeSummary?.baselineArtifacts.allSatisfy { $0.exists } == true ? "kompletny" : "w toku",
                        isDone: runtimeSummary?.baselineArtifacts.allSatisfy { $0.exists } == true
                    )
                    progressStep(
                        title: "3. Pierwsza idea",
                        detail: lastAddIdeaResult?.ideaState ?? "czeka",
                        isDone: lastAddIdeaResult?.result.isSuccess == true
                    )
                }
            }
        }
    }

    var newProjectPanel: some View {
        card {
            VStack(alignment: .leading, spacing: 18) {
                headerBlock(
                    eyebrow: "Entrypoint `new_project`",
                    title: "Uruchom nowy projekt i przygotuj baseline",
                    subtitle: "Wypelnij dane projektu, wybierz profile wykonania i zdecyduj o przejsciu przez gate baseline."
                )

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        formField("Nazwa projektu") {
                            TextField("Starter DS", text: $projectName)
                                .textFieldStyle(.roundedBorder)
                        }
                        formField("Sciezka projektu") {
                            TextField("~/Projects/starter-ds", text: $projectRootPath)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    GridRow {
                        formField("Stack") {
                            Picker("Stack", selection: $stack) {
                                ForEach(stacks, id: \.self) { value in
                                    Text(value).tag(value)
                                }
                            }
                        }
                        formField("Architektura") {
                            Picker("Architecture", selection: $architecture) {
                                ForEach(architectures, id: \.self) { value in
                                    Text(value).tag(value)
                                }
                            }
                        }
                    }

                    GridRow {
                        formField("Jezyk") {
                            Picker("Language", selection: $language) {
                                ForEach(languages, id: \.self) { value in
                                    Text(value).tag(value)
                                }
                            }
                        }
                        formField("Tryb wykonania") {
                            Picker("Execution style", selection: $executionStyle) {
                                ForEach(executionStyles, id: \.self) { value in
                                    Text(value).tag(value)
                                }
                            }
                        }
                    }

                    GridRow {
                        formField("Storage") {
                            Picker("Storage", selection: $storageProfile) {
                                Text("file-ai").tag(StorageProfile.fileAI)
                                Text("sqlbase").tag(StorageProfile.sqlbase)
                            }
                        }
                        formField("Repozytorium zdalne") {
                            Toggle("Utworz lub podlacz GitHub repo", isOn: $createRemoteRepository)
                                .toggleStyle(.switch)
                        }
                    }
                }

                formField("Opis projektu") {
                    TextEditor(text: $projectDescription)
                        .font(.system(.body, design: .rounded))
                        .frame(minHeight: 120)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                }

                gatePanel(
                    title: "Gate baseline",
                    caption: "Ta decyzja domyka baseline i przesuwa `Project` do `baseline-approved` albo pozostawia go w korekcie.",
                    decision: $baselineDecision,
                    reason: $baselineReason
                )

                HStack(spacing: 12) {
                    Button("Uruchom nowy projekt") {
                        runNewProject()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Uruchom starter end-to-end") {
                        runNewProject()
                        guard lastNewProjectResult?.result.isSuccess == true else {
                            return
                        }
                        addIdea()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
    }

    func baselineReadinessPanel(_ summary: PlaybookRuntimeSummary) -> some View {
        card {
            VStack(alignment: .leading, spacing: 16) {
                headerBlock(
                    eyebrow: "Baseline",
                    title: "Stan gotowosci po `new_project`",
                    subtitle: summary.projectState == "active"
                        ? "Projekt jest aktywny. Mozesz przejsc do pierwszej idei."
                        : "Projekt nie jest jeszcze aktywny. Sprawdz brakujace artefakty albo gate baseline."
                )

                VStack(spacing: 10) {
                    ForEach(summary.baselineArtifacts) { artifact in
                        HStack(spacing: 12) {
                            Image(systemName: artifact.exists ? "checkmark.circle.fill" : "circle.dashed")
                                .foregroundStyle(artifact.exists ? Color.green : Color.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(artifact.label)
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                Text(artifact.path)
                                    .font(.footnote.monospaced())
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            Spacer()
                        }
                    }
                }

                HStack(spacing: 18) {
                    metricBlock(title: "OP", value: "\(summary.allOps.count)")
                    metricBlock(title: "Eventy", value: "\(summary.processEventCount)")
                    metricBlock(title: "Gate", value: "\(summary.gateDecisionCount)")
                    metricBlock(title: "Evidence", value: "\(summary.evidenceCount)")
                }
            }
        }
    }

    var ideaPanel: some View {
        card {
            VStack(alignment: .leading, spacing: 18) {
                headerBlock(
                    eyebrow: "Entrypoint `add_idea`",
                    title: "Zapisz pierwsza idee i wygeneruj pochodne OP",
                    subtitle: "Ten krok zapisuje idee, uruchamia pochodne OP i pozostawia jawny envelope decyzji dla gate konwersji."
                )

                formField("Tytul idei") {
                    TextField("Uruchomienie projektu z UI", text: $ideaTitle)
                        .textFieldStyle(.roundedBorder)
                }

                formField("Opis idei") {
                    TextField("Operator tworzy projekt, baseline i pochodne OP w jednym nadzorowanym flow.", text: $ideaDescription)
                        .textFieldStyle(.roundedBorder)
                }

                gatePanel(
                    title: "Gate konwersji idei",
                    caption: "Zdecyduj czy idea przechodzi do `converted`, czy zostaje w korekcie albo odrzucona.",
                    decision: $ideaDecision,
                    reason: $ideaReason
                )

                Button("Dodaj pierwsza idee") {
                    addIdea()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(runtimeSummary?.projectState != "active")

                if runtimeSummary?.projectState != "active" {
                    Text("Idea jest zablokowana, dopoki projekt nie przejdzie do stanu `active`.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    func auditPanel(_ summary: PlaybookRuntimeSummary) -> some View {
        card {
            DisclosureGroup(isExpanded: $showAuditDetails) {
                VStack(alignment: .leading, spacing: 12) {
                    detailRow("Stan projektu", summary.projectState ?? "n/a")
                    detailRow("Remote URL", summary.remoteURL ?? "niepodlaczone")
                    detailRow("Ostatnia klasa evidence", summary.lastEvidenceClass ?? "brak")
                    detailRow("Liczba evidence", "\(summary.evidenceCount)")
                    detailRow("Ostatni event", summary.lastEventID ?? "n/a")

                    Divider()

                    Text("Biezacy graf OP")
                        .font(.system(.headline, design: .rounded))

                    ForEach(summary.allOps) { op in
                        HStack {
                            Text(op.opType)
                                .font(.system(.body, design: .rounded).weight(.semibold))
                            Spacer()
                            Text(op.opID)
                                .font(.footnote.monospaced())
                                .foregroundStyle(.secondary)
                            Text(op.state)
                                .font(.footnote.monospaced())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.06), in: Capsule())
                        }
                    }
                }
                .padding(.top, 12)
            } label: {
                headerBlock(
                    eyebrow: "Audit / Debug",
                    title: "Pokaz szczegoly runtime i provenance",
                    subtitle: "Ta sekcja jest drugoplanowa: trzyma trace, stan OP i evidence, ale nie prowadzi operatora przez glowny task."
                )
            }
        }
    }

    func outcomePanel(
        title: String,
        subtitle: String,
        result: RegistryOperationResult,
        details: [(String, String)]
    ) -> some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text(statusText(for: result))
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(result.isSuccess ? Color.green : Color.red)

                ForEach(details, id: \.0) { detail in
                    detailRow(detail.0, detail.1)
                }
            }
        }
    }

    func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 18, x: 0, y: 10)
    }

    func headerBlock(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(Color(red: 0.82, green: 0.42, blue: 0.12))
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.bold))
            Text(subtitle)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    func formField<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
            content()
        }
    }

    func gatePanel(
        title: String,
        caption: String,
        decision: Binding<PlaybookGateDecision>,
        reason: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.headline, design: .rounded))
            Text(caption)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Picker(title, selection: decision) {
                ForEach(PlaybookGateDecision.allCases) { value in
                    Text(value.label).tag(value)
                }
            }
            .pickerStyle(.segmented)
            TextField("Powod decyzji", text: reason)
                .textFieldStyle(.roundedBorder)
        }
        .padding(16)
        .background(Color(red: 0.97, green: 0.95, blue: 0.90), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    func progressStep(title: String, detail: String, isDone: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(isDone ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
            }
            Text(detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(.caption, design: .rounded).weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.18), in: Capsule())
    }

    func chip(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
            Text(subtitle)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .frame(width: 160, alignment: .leading)
            Text(value)
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }

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

    func statusText(for result: RegistryOperationResult) -> String {
        switch result {
        case .success:
            return "Status: success"
        case let .failure(reason):
            return "Status: failure (\(reason.message))"
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

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
