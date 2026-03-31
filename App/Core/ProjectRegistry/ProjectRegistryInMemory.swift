import Foundation

final class ProjectRegistryInMemory: ProjectRegistryContract {
    nonisolated deinit {}

    private var projectsByID: [ProjectID: ProjectRecord] = [:]
    private var orderedProjectIDs: [ProjectID] = []
    private var selectedProjectID: ProjectID?
    private var dataByProjectID: [ProjectID: ProjectScopedData] = [:]
    private var pathAvailabilityByProjectID: [ProjectID: Bool] = [:]
    private var nextProjectNumber = 1

    func registerProject(name: String, localPath: String) -> ProjectRegistrationResult {
        guard !name.isEmpty, !localPath.isEmpty else {
            return ProjectRegistrationResult(
                result: .failure(.init(message: "Project name and local path are required.")),
                createdProjectID: nil
            )
        }

        guard !activeProjectPathExists(localPath, excluding: nil) else {
            return ProjectRegistrationResult(
                result: .failure(.init(message: "An active project with this local path already exists.")),
                createdProjectID: nil
            )
        }

        let id = ProjectID(rawValue: "P-\(nextProjectNumber)")
        nextProjectNumber += 1

        let project = ProjectRecord(
            id: id,
            name: name,
            localPath: localPath,
            status: .active,
            history: []
        )

        projectsByID[id] = project
        orderedProjectIDs.append(id)
        pathAvailabilityByProjectID[id] = true

        return ProjectRegistrationResult(result: .success, createdProjectID: id)
    }

    func listProjects() -> [ProjectRecord] {
        orderedProjectIDs.compactMap { projectsByID[$0] }
    }

    func project(by id: ProjectID) -> ProjectRecord? {
        projectsByID[id]
    }

    func updateProjectMetadata(id: ProjectID, name: String?, localPath: String?) -> RegistryOperationResult {
        guard var existing = projectsByID[id] else {
            return .failure(.init(message: "Project not found."))
        }

        if let updatedName = name, updatedName.isEmpty {
            return .failure(.init(message: "Project name cannot be empty."))
        }

        if let updatedPath = localPath, updatedPath.isEmpty {
            return .failure(.init(message: "Project local path cannot be empty."))
        }

        if let updatedPath = localPath, existing.status == .active,
           activeProjectPathExists(updatedPath, excluding: id)
        {
            return .failure(.init(message: "Another active project already uses this local path."))
        }

        existing = ProjectRecord(
            id: existing.id,
            name: name ?? existing.name,
            localPath: localPath ?? existing.localPath,
            status: existing.status,
            history: existing.history
        )
        projectsByID[id] = existing
        return .success
    }

    func archiveProject(id: ProjectID) -> RegistryOperationResult {
        guard let existing = projectsByID[id] else {
            return .failure(.init(message: "Project not found."))
        }

        guard existing.status == .active else {
            return .failure(.init(message: "Project is already archived."))
        }

        projectsByID[id] = ProjectRecord(
            id: existing.id,
            name: existing.name,
            localPath: existing.localPath,
            status: .archived,
            history: existing.history
        )

        if selectedProjectID == id {
            selectedProjectID = nil
        }

        return .success
    }

    func reactivateProject(id: ProjectID) -> RegistryOperationResult {
        guard let existing = projectsByID[id] else {
            return .failure(.init(message: "Project not found."))
        }

        guard existing.status == .archived else {
            return .failure(.init(message: "Project is already active."))
        }

        guard !activeProjectPathExists(existing.localPath, excluding: id) else {
            return .failure(.init(message: "Another active project already uses this local path."))
        }

        projectsByID[id] = ProjectRecord(
            id: existing.id,
            name: existing.name,
            localPath: existing.localPath,
            status: .active,
            history: existing.history
        )
        return .success
    }

    func selectActiveWorkingProject(id: ProjectID) -> RegistryOperationResult {
        guard let project = projectsByID[id] else {
            selectedProjectID = nil
            return .failure(.init(message: "Project not found."))
        }

        guard project.status == .active else {
            selectedProjectID = nil
            return .failure(.init(message: "Archived project cannot be selected as active working project."))
        }

        selectedProjectID = id
        return .success
    }

    func activeWorkingProjectID() -> ProjectID? {
        selectedProjectID
    }

    func performFeatureLevelOperation() -> RegistryOperationResult {
        guard selectedProjectID != nil else {
            return .failure(.init(message: "No active working project selected."))
        }
        return .success
    }

    func performPathRequiredOperation(for id: ProjectID) -> RegistryOperationResult {
        guard projectsByID[id] != nil else {
            return .failure(.init(message: "Project not found."))
        }

        let isAvailable = pathAvailabilityByProjectID[id, default: true]
        guard isAvailable else {
            return .failure(.init(message: "Project local path is unavailable."))
        }

        return .success
    }

    func seedScopedData(for id: ProjectID, data: ProjectScopedData) {
        dataByProjectID[id] = data
    }

    func scopedData(for id: ProjectID) -> ProjectScopedData? {
        dataByProjectID[id]
    }

    func setPathAvailability(for id: ProjectID, isAvailable: Bool) {
        pathAvailabilityByProjectID[id] = isAvailable
    }

    private func activeProjectPathExists(_ localPath: String, excluding excludedID: ProjectID?) -> Bool {
        projectsByID.values.contains { project in
            project.status == .active &&
                project.localPath == localPath &&
                project.id != excludedID
        }
    }
}
