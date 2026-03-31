import Foundation

final class PRDToBDDFlowInMemory: PRDToBDDFlowContract {
    nonisolated deinit {}

    private struct ContextAvailability {
        var overview = true
        var constraints = true
        var glossary = true
        var stackRules = true

        var allRequiredAvailable: Bool {
            overview && constraints && glossary && stackRules
        }
    }

    private var selectedProjectID: ProjectID?
    private var contextAvailability = ContextAvailability()
    private var traces: [BDDFromPRDPromptTrace] = []

    var didSendPromptToAIProvider: Bool {
        false
    }

    func selectActiveProject(id: ProjectID?) {
        selectedProjectID = id
    }

    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool) {
        contextAvailability = ContextAvailability(
            overview: overview,
            constraints: constraints,
            glossary: glossary,
            stackRules: stackRules
        )
    }

    func generateBDDPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        prdDocument: String
    ) -> BDDFromPRDPromptResult {
        guard let activeProjectID = selectedProjectID else {
            return failureResult(message: "No active project selected.", ideaID: nil, projectID: nil)
        }

        let trimmedTitle = ideaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return failureResult(
                message: "Idea title is required for PRD -> BDD.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        let normalizedPRD = prdDocument.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedPRD.isEmpty else {
            return failureResult(
                message: "PRD document is required for PRD -> BDD.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        guard contextAvailability.allRequiredAvailable else {
            return failureResult(
                message: "Required context sources are unavailable.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        let promptText = buildPrompt(
            projectID: activeProjectID,
            ideaID: ideaID,
            ideaTitle: trimmedTitle,
            prdDocument: normalizedPRD
        )
        let fingerprint = "\(activeProjectID.rawValue)|\(ideaID.rawValue)|\(trimmedTitle)|\(normalizedPRD)"

        traces.append(
            BDDFromPRDPromptTrace(
                operation: "PRD -> BDD",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        )

        return BDDFromPRDPromptResult(
            result: .success,
            promptText: promptText,
            promptFingerprint: fingerprint,
            includesMinimalContext: true,
            ideaID: ideaID,
            projectID: activeProjectID,
            prdLength: normalizedPRD.count
        )
    }

    func lastTrace() -> BDDFromPRDPromptTrace? {
        traces.last
    }

    private func failureResult(
        message: String,
        ideaID: IdeaID?,
        projectID: ProjectID?
    ) -> BDDFromPRDPromptResult {
        BDDFromPRDPromptResult(
            result: .failure(.init(message: message)),
            promptText: "",
            promptFingerprint: "",
            includesMinimalContext: false,
            ideaID: ideaID,
            projectID: projectID,
            prdLength: 0
        )
    }

    private func buildPrompt(
        projectID: ProjectID,
        ideaID: IdeaID,
        ideaTitle: String,
        prdDocument: String
    ) -> String {
        """
        PRD -> BDD
        project_id: \(projectID.rawValue)
        idea_id: \(ideaID.rawValue)
        idea_title: \(ideaTitle)
        context: overview,constraints,glossary,stack-rules
        prd_document:
        \(prdDocument)
        output: deterministic-bdd-scenarios
        """
    }
}
