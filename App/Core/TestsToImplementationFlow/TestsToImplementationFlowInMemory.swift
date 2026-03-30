import Foundation

final class TestsToImplementationFlowInMemory: TestsToImplementationFlowContract {
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
    private var traces: [ImplementationFromTestsPromptTrace] = []

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

    func generateImplementationPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        testsDocument: String
    ) -> ImplementationFromTestsPromptResult {
        guard let activeProjectID = selectedProjectID else {
            return failureResult(message: "No active project selected.", ideaID: nil, projectID: nil)
        }

        let trimmedTitle = ideaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return failureResult(
                message: "Idea title is required for TESTS -> IMPLEMENTATION.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        let normalizedTests = testsDocument.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTests.isEmpty else {
            return failureResult(
                message: "Tests document is required for TESTS -> IMPLEMENTATION.",
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
            testsDocument: normalizedTests
        )
        let fingerprint = "\(activeProjectID.rawValue)|\(ideaID.rawValue)|\(trimmedTitle)|\(normalizedTests)"

        traces.append(
            ImplementationFromTestsPromptTrace(
                operation: "TESTS -> IMPLEMENTATION",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        )

        return ImplementationFromTestsPromptResult(
            result: .success,
            promptText: promptText,
            promptFingerprint: fingerprint,
            includesMinimalContext: true,
            ideaID: ideaID,
            projectID: activeProjectID,
            testsLength: normalizedTests.count
        )
    }

    func lastTrace() -> ImplementationFromTestsPromptTrace? {
        traces.last
    }

    private func failureResult(
        message: String,
        ideaID: IdeaID?,
        projectID: ProjectID?
    ) -> ImplementationFromTestsPromptResult {
        ImplementationFromTestsPromptResult(
            result: .failure(.init(message: message)),
            promptText: "",
            promptFingerprint: "",
            includesMinimalContext: false,
            ideaID: ideaID,
            projectID: projectID,
            testsLength: 0
        )
    }

    private func buildPrompt(
        projectID: ProjectID,
        ideaID: IdeaID,
        ideaTitle: String,
        testsDocument: String
    ) -> String {
        """
        TESTS -> IMPLEMENTATION
        project_id: \(projectID.rawValue)
        idea_id: \(ideaID.rawValue)
        idea_title: \(ideaTitle)
        context: overview,constraints,glossary,stack-rules
        tests_document:
        \(testsDocument)
        output: deterministic-implementation-plan-and-batches
        """
    }
}
