import Foundation

final class IdeaToPRDFlowInMemory: IdeaToPRDFlowContract {
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
    private var ideasByID: [IdeaID: IdeaRecord] = [:]
    private var contextAvailability = ContextAvailability()
    private var traces: [PRDPromptGenerationTrace] = []

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

    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool) {
        contextAvailability = ContextAvailability(
            overview: overview,
            constraints: constraints,
            glossary: glossary,
            stackRules: stackRules
        )
    }

    func generatePRDPrompt(for ideaID: IdeaID) -> PRDPromptGenerationResult {
        guard let activeProjectID = selectedProjectID else {
            return PRDPromptGenerationResult(
                result: .failure(.init(message: "No active project selected.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: nil,
                projectID: nil
            )
        }

        guard let idea = ideasByID[ideaID], idea.projectID == activeProjectID else {
            return PRDPromptGenerationResult(
                result: .failure(.init(message: "Idea not found in active project scope.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: nil,
                projectID: nil
            )
        }

        guard contextAvailability.allRequiredAvailable else {
            return PRDPromptGenerationResult(
                result: .failure(.init(message: "Required context sources are unavailable.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: idea.id,
                projectID: activeProjectID
            )
        }

        let promptText = """
        IDEA -> PRD
        project_id: \(activeProjectID.rawValue)
        idea_id: \(idea.id.rawValue)
        idea_title: \(idea.title)
        context: overview,constraints,glossary,stack-rules
        output: deterministic-prd-draft
        """

        let fingerprint = "\(activeProjectID.rawValue)|\(idea.id.rawValue)|\(idea.title)|\(idea.status.rawValue)"

        traces.append(
            PRDPromptGenerationTrace(
                operation: "IDEA -> PRD",
                ideaID: idea.id,
                projectID: activeProjectID
            )
        )

        return PRDPromptGenerationResult(
            result: .success,
            promptText: promptText,
            promptFingerprint: fingerprint,
            includesMinimalContext: true,
            ideaID: idea.id,
            projectID: activeProjectID
        )
    }

    func idea(by id: IdeaID) -> IdeaRecord? {
        ideasByID[id]
    }

    func lastTrace() -> PRDPromptGenerationTrace? {
        traces.last
    }
}
