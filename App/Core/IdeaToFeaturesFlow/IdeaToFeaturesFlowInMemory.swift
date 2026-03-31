import Foundation

final class IdeaToFeaturesFlowInMemory: IdeaToFeaturesFlowContract {
    nonisolated deinit {}

    private struct ContextAvailability {
        var overview = true
        var constraints = true
        var glossary = true

        var allRequiredAvailable: Bool {
            overview && constraints && glossary
        }
    }

    private var selectedProjectID: ProjectID?
    private var ideasByID: [IdeaID: IdeaRecord] = [:]
    private var contextAvailability = ContextAvailability()
    private var traces: [FeatureSetPromptGenerationTrace] = []

    var didSendPromptToAIProvider: Bool {
        false
    }

    func selectActiveProject(id: ProjectID?) {
        selectedProjectID = id
    }

    func seedIdea(id: IdeaID, projectID: ProjectID, title: String, status: IdeaStatus) {
        ideasByID[id] = IdeaRecord(
            id: id,
            projectID: projectID,
            title: title,
            description: nil,
            status: status
        )
    }

    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool) {
        contextAvailability = ContextAvailability(
            overview: overview,
            constraints: constraints,
            glossary: glossary
        )
    }

    func generateFeaturesPrompt(for ideaID: IdeaID) -> FeatureSetPromptGenerationResult {
        guard let activeProjectID = selectedProjectID else {
            return failureResult(message: "No active project selected.", ideaID: nil, projectID: nil)
        }

        guard let idea = ideasByID[ideaID], idea.projectID == activeProjectID else {
            return failureResult(
                message: "Idea not found in active project scope.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        guard idea.status == .selected else {
            return failureResult(
                message: "Idea must be in selected status before IDEA -> FEATURES.",
                ideaID: idea.id,
                projectID: activeProjectID
            )
        }

        guard contextAvailability.allRequiredAvailable else {
            return failureResult(
                message: "Required context sources are unavailable.",
                ideaID: idea.id,
                projectID: activeProjectID
            )
        }

        let proposedFeatures = deriveDeterministicFeatures(from: idea)
        let promptText = buildPrompt(
            projectID: activeProjectID,
            idea: idea,
            proposedFeatures: proposedFeatures
        )
        let fingerprint = "\(activeProjectID.rawValue)|\(idea.id.rawValue)|\(idea.title)|\(idea.status.rawValue)"

        traces.append(
            FeatureSetPromptGenerationTrace(
                operation: "IDEA -> FEATURES",
                ideaID: idea.id,
                projectID: activeProjectID
            )
        )

        return FeatureSetPromptGenerationResult(
            result: .success,
            promptText: promptText,
            promptFingerprint: fingerprint,
            includesMinimalContext: true,
            ideaID: idea.id,
            projectID: activeProjectID,
            proposedFeatures: proposedFeatures
        )
    }

    func idea(by id: IdeaID) -> IdeaRecord? {
        ideasByID[id]
    }

    func lastTrace() -> FeatureSetPromptGenerationTrace? {
        traces.last
    }

    private func failureResult(
        message: String,
        ideaID: IdeaID?,
        projectID: ProjectID?
    ) -> FeatureSetPromptGenerationResult {
        FeatureSetPromptGenerationResult(
            result: .failure(.init(message: message)),
            promptText: "",
            promptFingerprint: "",
            includesMinimalContext: false,
            ideaID: ideaID,
            projectID: projectID,
            proposedFeatures: []
        )
    }

    private func deriveDeterministicFeatures(from idea: IdeaRecord) -> [FeatureCandidate] {
        let base = idea.title.trimmingCharacters(in: .whitespacesAndNewlines)

        return [
            FeatureCandidate(
                key: "F-1",
                name: "\(base): zakres funkcjonalny",
                description: "Zdefiniuj jawny zakres i granice realizowanej funkcjonalności."
            ),
            FeatureCandidate(
                key: "F-2",
                name: "\(base): walidacja i reguły",
                description: "Zdefiniuj zasady walidacji, przypadki brzegowe i kryteria akceptacji."
            ),
            FeatureCandidate(
                key: "F-3",
                name: "\(base): integracja i obserwowalność",
                description: "Określ punkty integracji, traceability i sygnały diagnostyczne."
            ),
        ]
    }

    private func buildPrompt(
        projectID: ProjectID,
        idea: IdeaRecord,
        proposedFeatures: [FeatureCandidate]
    ) -> String {
        let featuresBlock = proposedFeatures
            .map { "- \($0.key): \($0.name) | \($0.description)" }
            .joined(separator: "\n")

        return """
        IDEA -> FEATURES
        project_id: \(projectID.rawValue)
        idea_id: \(idea.id.rawValue)
        idea_title: \(idea.title)
        context: overview,constraints,glossary
        proposed_features:
        \(featuresBlock)
        output: deterministic-feature-set
        """
    }
}
