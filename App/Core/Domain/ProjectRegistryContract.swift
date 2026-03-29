protocol ProjectRegistryContract {
    func registerProject(name: String, localPath: String) -> ProjectRegistrationResult
    func listProjects() -> [ProjectRecord]
    func project(by id: ProjectID) -> ProjectRecord?

    func updateProjectMetadata(id: ProjectID, name: String?, localPath: String?) -> RegistryOperationResult
    func archiveProject(id: ProjectID) -> RegistryOperationResult
    func reactivateProject(id: ProjectID) -> RegistryOperationResult

    func selectActiveWorkingProject(id: ProjectID) -> RegistryOperationResult
    func activeWorkingProjectID() -> ProjectID?

    func performFeatureLevelOperation() -> RegistryOperationResult
    func performPathRequiredOperation(for id: ProjectID) -> RegistryOperationResult

    func seedScopedData(for id: ProjectID, data: ProjectScopedData)
    func scopedData(for id: ProjectID) -> ProjectScopedData?
    func setPathAvailability(for id: ProjectID, isAvailable: Bool)
}
