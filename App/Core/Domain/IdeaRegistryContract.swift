protocol IdeaRegistryContract {
    func selectActiveProject(id: ProjectID?)

    func createIdea(title: String, description: String?) -> IdeaCreationResult
    func updateIdeaContent(id: IdeaID, title: String, description: String?) -> RegistryOperationResult
    func changeIdeaStatus(id: IdeaID, rawStatus: String) -> RegistryOperationResult

    func listIdeasForActiveProject() -> IdeaListResult
    func idea(by id: IdeaID) -> IdeaRecord?
}

extension IdeaRegistryContract {
    func changeIdeaStatus(id: IdeaID, status: IdeaStatus) -> RegistryOperationResult {
        changeIdeaStatus(id: id, rawStatus: status.rawValue)
    }
}
