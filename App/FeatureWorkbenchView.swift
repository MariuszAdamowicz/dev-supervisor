import SwiftUI

struct WorkspaceProject: Identifiable, Equatable {
    let record: ProjectRecord
    let storageProfile: StorageProfile

    var id: String {
        record.id.rawValue
    }
}

enum FeatureWorkbenchStep: String, CaseIterable, Identifiable {
    case featureSet
    case prd
    case bdd
    case tests
    case implementation
    case validation

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .featureSet:
            return "Feature"
        case .prd:
            return "PRD"
        case .bdd:
            return "BDD"
        case .tests:
            return "Testy"
        case .implementation:
            return "Implementacja"
        case .validation:
            return "Walidacja"
        }
    }

    var operatorGoal: String {
        switch self {
        case .featureSet:
            return "Zamień ideę w jeden jawny zakres funkcji."
        case .prd:
            return "Opisz funkcję jako spójny dokument produktu."
        case .bdd:
            return "Rozbij PRD na scenariusze zachowania."
        case .tests:
            return "Zapisz strategię i przypadki testowe."
        case .implementation:
            return "Wyprowadź plan implementacji z testów."
        case .validation:
            return "Zamknij funkcję planem walidacji i stabilizacji."
        }
    }

    var inputLabel: String {
        switch self {
        case .featureSet:
            return "Idea"
        case .prd:
            return "Feature set"
        case .bdd:
            return "PRD"
        case .tests:
            return "BDD"
        case .implementation:
            return "Testy"
        case .validation:
            return "Implementacja"
        }
    }

    var outputLabel: String {
        switch self {
        case .featureSet:
            return "Feature set"
        case .prd:
            return "PRD"
        case .bdd:
            return "BDD"
        case .tests:
            return "Testy"
        case .implementation:
            return "Implementacja"
        case .validation:
            return "Walidacja"
        }
    }
}

struct FeatureWorkbenchState: Equatable {
    var selectedStep: FeatureWorkbenchStep = .featureSet
    var featurePromptResult: FeatureSetPromptGenerationResult?
    var featurePromptPath: String?
    var approvedFeatures: [FeatureCandidate] = []
    var approvedFeaturesPath: String?
    var prdPromptResult: PRDFromFeaturesPromptResult?
    var prdPromptPath: String?
    var prdDraft = ""
    var prdArtifactPath: String?
    var bddPromptResult: BDDFromPRDPromptResult?
    var bddPromptPath: String?
    var bddDraft = ""
    var bddArtifactPath: String?
    var testsPromptResult: TestsFromBDDPromptResult?
    var testsPromptPath: String?
    var testsDraft = ""
    var testsArtifactPath: String?
    var implementationPromptResult: ImplementationFromTestsPromptResult?
    var implementationPromptPath: String?
    var implementationDraft = ""
    var implementationArtifactPath: String?
    var validationPromptResult: ValidationFromImplementationPromptResult?
    var validationPromptPath: String?
    var validationDraft = ""
    var validationArtifactPath: String?
    var traceabilityPath: String?
    var lastMessage: String?

    var recommendedStep: FeatureWorkbenchStep {
        if approvedFeatures.isEmpty {
            return .featureSet
        }
        if prdDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .prd
        }
        if bddDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .bdd
        }
        if testsDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .tests
        }
        if implementationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .implementation
        }
        return .validation
    }

    func isCompleted(_ step: FeatureWorkbenchStep) -> Bool {
        switch step {
        case .featureSet:
            return !approvedFeatures.isEmpty
        case .prd:
            return !prdDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .bdd:
            return !bddDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .tests:
            return !testsDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .implementation:
            return !implementationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .validation:
            return !validationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

private struct DocumentStepCardModel {
    let step: FeatureWorkbenchStep
    let promptText: String
    let promptPath: String?
    let savedPath: String?
    let isGenerateDisabled: Bool
    let isApproveDisabled: Bool
    let generateAction: () -> Void
    let approveAction: () -> Void
}

struct FeatureWorkbenchView: View {
    let project: WorkspaceProject
    let idea: IdeaRecord
    let inspection: ProjectInspectionResult?
    let stackRulesAvailable: Bool
    @Binding var state: FeatureWorkbenchState
    let onSelectStep: (FeatureWorkbenchStep) -> Void
    let onGenerateFeatures: () -> Void
    let onApproveFeatures: () -> Void
    let onGeneratePRD: () -> Void
    let onApprovePRD: () -> Void
    let onGenerateBDD: () -> Void
    let onApproveBDD: () -> Void
    let onGenerateTests: () -> Void
    let onApproveTests: () -> Void
    let onGenerateImplementation: () -> Void
    let onApproveImplementation: () -> Void
    let onGenerateValidation: () -> Void
    let onApproveValidation: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                stepStrip
                activeStepCard
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private extension FeatureWorkbenchView {
    var isBaselineReady: Bool {
        guard let inspection else {
            return false
        }
        return inspection.productGatePassed && stackRulesAvailable
    }

    var missingContextItems: [String] {
        var missing = inspection?.missingProductArtifacts ?? ["overview", "constraints", "glossary"]
        if !stackRulesAvailable {
            missing.append("stack-rules")
        }
        return missing
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(idea.title)
                .font(.largeTitle.bold())
            Text(project.record.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
            if let description = idea.description?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty {
                Text(description)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                statusChip(title: "Projekt", value: project.record.id.rawValue)
                statusChip(title: "Storage", value: project.storageProfile.rawValue)
                statusChip(title: "Następny krok", value: state.recommendedStep.title)
            }
            if let traceabilityPath = state.traceabilityPath {
                Text("Traceability: \(traceabilityPath)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let message = state.lastMessage, !message.isEmpty {
                messageBanner(text: message, isError: false)
            }
            if !isBaselineReady {
                messageBanner(
                    text: "Flow jest zablokowany. Uzupełnij wymagany baseline: \(missingContextItems.joined(separator: ", ")).",
                    isError: true
                )
            }
        }
    }

    var stepStrip: some View {
        HStack(spacing: 10) {
            ForEach(FeatureWorkbenchStep.allCases) { step in
                Button {
                    onSelectStep(step)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.headline)
                        Text(stepStatusText(step))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(stepBackground(step))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    var activeStepCard: some View {
        switch state.selectedStep {
        case .featureSet:
            featureStepCard
        case .prd:
            documentStepCard(
                model: DocumentStepCardModel(
                    step: .prd,
                    promptText: state.prdPromptResult?.promptText ?? "",
                    promptPath: state.prdPromptPath,
                    savedPath: state.prdArtifactPath,
                    isGenerateDisabled: !isBaselineReady || state.approvedFeatures.isEmpty,
                    isApproveDisabled: state.prdDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    generateAction: onGeneratePRD,
                    approveAction: onApprovePRD
                ),
                draft: $state.prdDraft
            )
        case .bdd:
            documentStepCard(
                model: DocumentStepCardModel(
                    step: .bdd,
                    promptText: state.bddPromptResult?.promptText ?? "",
                    promptPath: state.bddPromptPath,
                    savedPath: state.bddArtifactPath,
                    isGenerateDisabled: !isBaselineReady || state.prdDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    isApproveDisabled: state.bddDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    generateAction: onGenerateBDD,
                    approveAction: onApproveBDD
                ),
                draft: $state.bddDraft
            )
        case .tests:
            documentStepCard(
                model: DocumentStepCardModel(
                    step: .tests,
                    promptText: state.testsPromptResult?.promptText ?? "",
                    promptPath: state.testsPromptPath,
                    savedPath: state.testsArtifactPath,
                    isGenerateDisabled: !isBaselineReady || state.bddDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    isApproveDisabled: state.testsDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    generateAction: onGenerateTests,
                    approveAction: onApproveTests
                ),
                draft: $state.testsDraft
            )
        case .implementation:
            documentStepCard(
                model: DocumentStepCardModel(
                    step: .implementation,
                    promptText: state.implementationPromptResult?.promptText ?? "",
                    promptPath: state.implementationPromptPath,
                    savedPath: state.implementationArtifactPath,
                    isGenerateDisabled: !isBaselineReady || state.testsDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    isApproveDisabled: state.implementationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    generateAction: onGenerateImplementation,
                    approveAction: onApproveImplementation
                ),
                draft: $state.implementationDraft
            )
        case .validation:
            documentStepCard(
                model: DocumentStepCardModel(
                    step: .validation,
                    promptText: state.validationPromptResult?.promptText ?? "",
                    promptPath: state.validationPromptPath,
                    savedPath: state.validationArtifactPath,
                    isGenerateDisabled: !isBaselineReady || state.implementationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    isApproveDisabled: state.validationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    generateAction: onGenerateValidation,
                    approveAction: onApproveValidation
                ),
                draft: $state.validationDraft
            )
        }
    }

    var featureStepCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(for: .featureSet)
            if state.approvedFeatures.isEmpty {
                Text("Zacznij od deterministycznego rozbicia idei na pojedynczy feature set.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Zatwierdzony feature set")
                    .font(.headline)
                featureList(state.approvedFeatures)
                if let savedPath = state.approvedFeaturesPath {
                    Text("Zapis: \(savedPath)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            if let promptText = state.featurePromptResult?.promptText, !promptText.isEmpty {
                promptBox(promptText: promptText, promptPath: state.featurePromptPath)
            }
            HStack(spacing: 12) {
                Button("Generuj feature set", action: onGenerateFeatures)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isBaselineReady)
                Button("Zatwierdź feature set", action: onApproveFeatures)
                    .buttonStyle(.bordered)
                    .disabled(state.featurePromptResult?.result.isSuccess != true)
            }
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func documentStepCard(model: DocumentStepCardModel, draft: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(for: model.step)
            if !model.promptText.isEmpty {
                promptBox(promptText: model.promptText, promptPath: model.promptPath)
            } else {
                Text("Wygeneruj prompt dla etapu \(model.step.title), a potem wklej lub dopracuj wynik pracy agenta.")
                    .foregroundStyle(.secondary)
            }
            TextEditor(text: draft)
                .font(.body.monospaced())
                .frame(minHeight: 280)
                .padding(10)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            if let savedPath = model.savedPath {
                Text("Zapis: \(savedPath)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Button("Generuj prompt", action: model.generateAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(model.isGenerateDisabled)
                Button("Zatwierdź \(model.step.outputLabel.lowercased())", action: model.approveAction)
                    .buttonStyle(.bordered)
                    .disabled(model.isApproveDisabled)
            }
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func featureList(_ features: [FeatureCandidate]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(features, id: \.key) { feature in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(feature.key) · \(feature.name)")
                        .font(.headline)
                    Text(feature.description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    func promptBox(promptText: String, promptPath: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prompt dla operatora / agenta")
                .font(.headline)
            if let promptPath {
                Text(promptPath)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ScrollView {
                Text(promptText)
                    .font(.footnote.monospaced())
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 150, maxHeight: 220)
            .padding(10)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    func stepHeader(for step: FeatureWorkbenchStep) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(step.title)
                .font(.title2.bold())
            Text(step.operatorGoal)
                .foregroundStyle(.secondary)
            Text("Wejście: \(step.inputLabel) · Wyjście: \(step.outputLabel)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func statusChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote.weight(.semibold))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    func messageBanner(text: String, isError: Bool) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(isError ? Color.red : Color.secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background((isError ? Color.red : Color.secondary).opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    func stepStatusText(_ step: FeatureWorkbenchStep) -> String {
        if state.isCompleted(step) {
            return "Gotowe"
        }
        if state.recommendedStep == step {
            return "Teraz"
        }
        return "Czeka"
    }

    func stepBackground(_ step: FeatureWorkbenchStep) -> Color {
        if state.isCompleted(step) {
            return Color.green.opacity(0.15)
        }
        if state.recommendedStep == step {
            return Color.accentColor.opacity(0.16)
        }
        return Color(nsColor: .controlBackgroundColor)
    }
}
