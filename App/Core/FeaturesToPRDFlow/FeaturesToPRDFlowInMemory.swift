import Foundation

final class FeaturesToPRDFlowInMemory: FeaturesToPRDFlowContract {
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
    private var traces: [PRDFromFeaturesPromptTrace] = []

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

    func generatePRDPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        features: [FeatureCandidate]
    ) -> PRDFromFeaturesPromptResult {
        guard let activeProjectID = selectedProjectID else {
            return failureResult(message: "No active project selected.", ideaID: nil, projectID: nil)
        }

        let trimmedTitle = ideaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return failureResult(
                message: "Idea title is required for FEATURES -> PRD.",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        }

        guard !features.isEmpty else {
            return failureResult(
                message: "At least one feature candidate is required.",
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
            features: features
        )

        let featureSignature = features
            .map { "\($0.key):\($0.name)" }
            .joined(separator: "|")
        let fingerprint = "\(activeProjectID.rawValue)|\(ideaID.rawValue)|\(trimmedTitle)|\(featureSignature)"

        traces.append(
            PRDFromFeaturesPromptTrace(
                operation: "FEATURES -> PRD",
                ideaID: ideaID,
                projectID: activeProjectID
            )
        )

        return PRDFromFeaturesPromptResult(
            result: .success,
            promptText: promptText,
            promptFingerprint: fingerprint,
            includesMinimalContext: true,
            ideaID: ideaID,
            projectID: activeProjectID,
            featuresCount: features.count
        )
    }

    func lastTrace() -> PRDFromFeaturesPromptTrace? {
        traces.last
    }

    private func failureResult(
        message: String,
        ideaID: IdeaID?,
        projectID: ProjectID?
    ) -> PRDFromFeaturesPromptResult {
        PRDFromFeaturesPromptResult(
            result: .failure(.init(message: message)),
            promptText: "",
            promptFingerprint: "",
            includesMinimalContext: false,
            ideaID: ideaID,
            projectID: projectID,
            featuresCount: 0
        )
    }

    private func buildPrompt(
        projectID: ProjectID,
        ideaID: IdeaID,
        ideaTitle: String,
        features: [FeatureCandidate]
    ) -> String {
        let featuresBlock = features
            .map { "- \($0.key): \($0.name) | \($0.description)" }
            .joined(separator: "\n")

        return """
        FEATURES -> PRD
        project_id: \(projectID.rawValue)
        idea_id: \(ideaID.rawValue)
        idea_title: \(ideaTitle)
        context: overview,constraints,glossary,stack-rules
        features:
        \(featuresBlock)
        output: deterministic-prd-draft
        """
    }
}
