import Foundation

final class BDDToTestsFlowInMemory: BDDToTestsFlowContract {
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
    private var traces: [TestsFromBDDPromptTrace] = []

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

    func generateTestsPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        bddDocument: String
    ) -> TestsFromBDDPromptResult {
        guard let activeProjectID = selectedProjectID else {
            return failureResult(message: "No active project selected.", ideaID: nil, projectID: nil)
        }

        let trimmedTitle = ideaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return failureResult(
                message: "Idea title is required for BDD -> TESTS.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        let normalizedBDD = bddDocument.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedBDD.isEmpty else {
            return failureResult(
                message: "BDD document is required for BDD -> TESTS.",
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
            bddDocument: normalizedBDD
        )
        let fingerprint = "\(activeProjectID.rawValue)|\(ideaID.rawValue)|\(trimmedTitle)|\(normalizedBDD)"

        traces.append(
            TestsFromBDDPromptTrace(
                operation: "BDD -> TESTS",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        )

        return TestsFromBDDPromptResult(
            result: .success,
            promptText: promptText,
            promptFingerprint: fingerprint,
            includesMinimalContext: true,
            ideaID: ideaID,
            projectID: activeProjectID,
            bddLength: normalizedBDD.count
        )
    }

    func lastTrace() -> TestsFromBDDPromptTrace? {
        traces.last
    }

    private func failureResult(
        message: String,
        ideaID: IdeaID?,
        projectID: ProjectID?
    ) -> TestsFromBDDPromptResult {
        TestsFromBDDPromptResult(
            result: .failure(.init(message: message)),
            promptText: "",
            promptFingerprint: "",
            includesMinimalContext: false,
            ideaID: ideaID,
            projectID: projectID,
            bddLength: 0
        )
    }

    private func buildPrompt(
        projectID: ProjectID,
        ideaID: IdeaID,
        ideaTitle: String,
        bddDocument: String
    ) -> String {
        """
        BDD -> TESTS
        project_id: \(projectID.rawValue)
        idea_id: \(ideaID.rawValue)
        idea_title: \(ideaTitle)
        context: overview,constraints,glossary,stack-rules
        bdd_document:
        \(bddDocument)
        output: deterministic-test-plan-and-test-cases
        """
    }
}
