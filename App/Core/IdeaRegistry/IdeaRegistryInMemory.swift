import Foundation

final class IdeaRegistryInMemory: IdeaRegistryContract {
    nonisolated deinit {}

    private var ideasByID: [IdeaID: IdeaRecord] = [:]
    private var orderedIdeaIDs: [IdeaID] = []
    private var selectedProjectID: ProjectID?
    private var nextIdeaNumber = 1

    func selectActiveProject(id: ProjectID?) {
        selectedProjectID = id
    }

    func createIdea(title: String, description: String?) -> IdeaCreationResult {
        guard let projectID = selectedProjectID else {
            return IdeaCreationResult(
                result: .failure(.init(message: "No active project selected.")),
                createdIdeaID: nil
            )
        }

        guard !title.isEmpty else {
            return IdeaCreationResult(
                result: .failure(.init(message: "Idea title cannot be empty.")),
                createdIdeaID: nil
            )
        }

        let id = IdeaID(rawValue: "I-\(nextIdeaNumber)")
        nextIdeaNumber += 1

        let record = IdeaRecord(
            id: id,
            projectID: projectID,
            title: title,
            description: description,
            status: .new
        )

        ideasByID[id] = record
        orderedIdeaIDs.append(id)

        return IdeaCreationResult(result: .success, createdIdeaID: id)
    }

    func updateIdeaContent(id: IdeaID, title: String, description: String?) -> RegistryOperationResult {
        guard selectedProjectID != nil else {
            return .failure(.init(message: "No active project selected."))
        }

        guard !title.isEmpty else {
            return .failure(.init(message: "Idea title cannot be empty."))
        }

        guard var existing = ideaInActiveProject(by: id) else {
            return .failure(.init(message: "Idea not found in active project scope."))
        }

        existing = IdeaRecord(
            id: existing.id,
            projectID: existing.projectID,
            title: title,
            description: description,
            status: existing.status
        )

        ideasByID[id] = existing
        return .success
    }

    func changeIdeaStatus(id: IdeaID, rawStatus: String) -> RegistryOperationResult {
        guard selectedProjectID != nil else {
            return .failure(.init(message: "No active project selected."))
        }

        guard let status = IdeaStatus(rawValue: rawStatus) else {
            return .failure(.init(message: "Invalid idea status value."))
        }

        guard var existing = ideaInActiveProject(by: id) else {
            return .failure(.init(message: "Idea not found in active project scope."))
        }

        if status == .selected, selectedIdeaExists(in: existing.projectID, excluding: id) {
            return .failure(.init(message: "Another idea is already selected in this project."))
        }

        existing = IdeaRecord(
            id: existing.id,
            projectID: existing.projectID,
            title: existing.title,
            description: existing.description,
            status: status
        )

        ideasByID[id] = existing
        return .success
    }

    func listIdeasForActiveProject() -> IdeaListResult {
        guard let activeProjectID = selectedProjectID else {
            return IdeaListResult(
                result: .failure(.init(message: "No active project selected.")),
                ideas: []
            )
        }

        let ideas = orderedIdeaIDs
            .compactMap { ideasByID[$0] }
            .filter { $0.projectID == activeProjectID }

        return IdeaListResult(result: .success, ideas: ideas)
    }

    func idea(by id: IdeaID) -> IdeaRecord? {
        ideasByID[id]
    }

    private func ideaInActiveProject(by id: IdeaID) -> IdeaRecord? {
        guard let activeProjectID = selectedProjectID,
              let existing = ideasByID[id],
              existing.projectID == activeProjectID
        else {
            return nil
        }

        return existing
    }

    private func selectedIdeaExists(in projectID: ProjectID, excluding excludedID: IdeaID) -> Bool {
        ideasByID.values.contains {
            $0.projectID == projectID && $0.id != excludedID && $0.status == .selected
        }
    }
}
