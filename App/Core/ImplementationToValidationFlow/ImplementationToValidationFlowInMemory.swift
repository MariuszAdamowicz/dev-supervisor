import Foundation

final class ImplementationToValidationFlowInMemory: ImplementationToValidationFlowContract {
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
    private var traces: [ValidationFromImplementationPromptTrace] = []

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

    func generateValidationPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        implementationDocument: String
    ) -> ValidationFromImplementationPromptResult {
        guard let activeProjectID = selectedProjectID else {
            return failureResult(message: "No active project selected.", ideaID: nil, projectID: nil)
        }

        let trimmedTitle = ideaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return failureResult(
                message: "Idea title is required for IMPLEMENTATION -> VALIDATION.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        let normalizedImplementation = implementationDocument.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedImplementation.isEmpty else {
            return failureResult(
                message: "Implementation document is required for IMPLEMENTATION -> VALIDATION.",
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
            implementationDocument: normalizedImplementation
        )
        let fingerprint = "\(activeProjectID.rawValue)|\(ideaID.rawValue)|\(trimmedTitle)|\(normalizedImplementation)"

        traces.append(
            ValidationFromImplementationPromptTrace(
                operation: "IMPLEMENTATION -> VALIDATION",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        )

        return ValidationFromImplementationPromptResult(
            result: .success,
            promptText: promptText,
            promptFingerprint: fingerprint,
            includesMinimalContext: true,
            ideaID: ideaID,
            projectID: activeProjectID,
            implementationLength: normalizedImplementation.count
        )
    }

    func lastTrace() -> ValidationFromImplementationPromptTrace? {
        traces.last
    }

    private func failureResult(
        message: String,
        ideaID: IdeaID?,
        projectID: ProjectID?
    ) -> ValidationFromImplementationPromptResult {
        ValidationFromImplementationPromptResult(
            result: .failure(.init(message: message)),
            promptText: "",
            promptFingerprint: "",
            includesMinimalContext: false,
            ideaID: ideaID,
            projectID: projectID,
            implementationLength: 0
        )
    }

    private func buildPrompt(
        projectID: ProjectID,
        ideaID: IdeaID,
        ideaTitle: String,
        implementationDocument: String
    ) -> String {
        """
        IMPLEMENTATION -> VALIDATION
        project_id: \(projectID.rawValue)
        idea_id: \(ideaID.rawValue)
        idea_title: \(ideaTitle)
        context: overview,constraints,glossary,stack-rules
        implementation_document:
        \(implementationDocument)
        output: deterministic-validation-and-hardening-plan
        """
    }
}
