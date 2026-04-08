import SwiftUI

extension ContentView {
    func prepareCreateProjectSheet() {
        if createProjectDraft.rootPath.isEmpty {
            createProjectDraft.rootPath = defaultProjectsRootPath()
        }
        showCreateProjectSheet = true
    }

    func defaultProjectsRootPath() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Projects"
    }

    func refreshWorkspace(retainingSelection: Bool) {
        let allProjects = wrappedProjects()
        projects = allProjects

        let preferredProjectID = retainingSelection ? currentOrPersistedProjectID(in: allProjects) : nil
        guard let preferredProjectID,
              let preferredProject = allProjects.first(where: { $0.id == preferredProjectID })
        else {
            selectedProjectID = nil
            selectedIdeaID = nil
            ideas = []
            activeInspection = nil
            workbenchState = FeatureWorkbenchState()
            return
        }

        selectProject(preferredProject, retainingIdeaSelection: retainingSelection)
    }

    func wrappedProjects() -> [WorkspaceProject] {
        let fileAIProjects = fileAIProjectRegistryService.listProjects()
            .filter { $0.status == .active }
            .map { WorkspaceProject(record: $0, storageProfile: .fileAI) }
        let sqlbaseProjects = sqlbaseProjectRegistryService.listProjects()
            .filter { $0.status == .active }
            .map { WorkspaceProject(record: $0, storageProfile: .sqlbase) }

        return (fileAIProjects + sqlbaseProjects).sorted {
            $0.record.name.localizedCaseInsensitiveCompare($1.record.name) == .orderedAscending
        }
    }

    func currentOrPersistedProjectID(in projects: [WorkspaceProject]) -> String? {
        if let selectedProjectID, projects.contains(where: { $0.id == selectedProjectID }) {
            return selectedProjectID
        }

        let persistedIDs = [
            sqlbaseProjectRegistryService.activeWorkingProjectID()?.rawValue,
            fileAIProjectRegistryService.activeWorkingProjectID()?.rawValue,
        ].compactMap { $0 }

        return persistedIDs.first { id in
            projects.contains(where: { $0.id == id })
        }
    }

    func selectProject(_ project: WorkspaceProject, retainingIdeaSelection: Bool = false) {
        selectedProjectID = project.id
        _ = projectRegistryService(for: project.storageProfile)
            .selectActiveWorkingProject(id: project.record.id)
        activeInspection = bootstrapService.inspectProject(at: project.record.localPath)
        refreshIdeas(in: project, retainingSelection: retainingIdeaSelection)
        setWorkspaceNotice(message: "Wybrano projekt \(project.record.name).", isError: false)
    }

    func refreshIdeas(in project: WorkspaceProject, retainingSelection: Bool) {
        let registry = ideaRegistryService(for: project.storageProfile)
        registry.selectActiveProject(id: project.record.id)
        let listResult = registry.listIdeasForActiveProject()
        ideas = listResult.ideas.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }

        let nextIdeaID: String?
        if retainingSelection,
           let selectedIdeaID,
           ideas.contains(where: { $0.id.rawValue == selectedIdeaID })
        {
            nextIdeaID = selectedIdeaID
        } else {
            nextIdeaID = ideas.first(where: { $0.status == .selected })?.id.rawValue
                ?? ideas.first?.id.rawValue
        }

        selectedIdeaID = nextIdeaID
        guard let nextIdeaID,
              let idea = ideas.first(where: { $0.id.rawValue == nextIdeaID })
        else {
            workbenchState = FeatureWorkbenchState()
            return
        }

        loadWorkbench(for: project, idea: idea)
    }

    func selectIdea(_ idea: IdeaRecord, in project: WorkspaceProject) {
        let registry = ideaRegistryService(for: project.storageProfile)
        registry.selectActiveProject(id: project.record.id)
        _ = registry.changeIdeaStatus(id: idea.id, status: .selected)
        selectedIdeaID = idea.id.rawValue
        refreshIdeas(in: project, retainingSelection: true)
        setWorkspaceNotice(message: "Aktywna idea: \(idea.title).", isError: false)
    }

    func createProject() {
        let input = ProjectBootstrapInput(
            projectName: createProjectDraft.name,
            projectsRootPath: createProjectDraft.rootPath,
            storageProfile: createProjectDraft.storageProfile,
            initializeGitRepository: createProjectDraft.initializeGitRepository
        )
        let result = bootstrapService.bootstrapProject(input)
        guard result.result.isSuccess, let projectPath = result.projectPath else {
            setWorkspaceNotice(
                message: errorMessage(from: result.result, fallback: "Nie udało się utworzyć projektu."),
                isError: true
            )
            return
        }

        showCreateProjectSheet = false
        registerProjectIfNeeded(
            name: createProjectDraft.name.trimmingCharacters(in: .whitespacesAndNewlines),
            localPath: projectPath,
            preferredStorageProfile: createProjectDraft.storageProfile
        )
    }

    func attachProject() {
        let trimmedPath = attachProjectDraft.path.trimmingCharacters(in: .whitespacesAndNewlines)
        let inspection = bootstrapService.inspectProject(at: trimmedPath)
        guard inspection.result.isSuccess else {
            setWorkspaceNotice(
                message: errorMessage(from: inspection.result, fallback: "Nie udało się otworzyć projektu."),
                isError: true
            )
            return
        }

        showAttachProjectSheet = false
        registerProjectIfNeeded(
            name: URL(fileURLWithPath: trimmedPath).lastPathComponent,
            localPath: trimmedPath,
            preferredStorageProfile: inspection.detectedStorageProfile ?? .fileAI
        )
    }

    func registerProjectIfNeeded(name: String, localPath: String, preferredStorageProfile: StorageProfile) {
        if let existingProject = workspaceProject(matchingPath: localPath) {
            refreshWorkspace(retainingSelection: false)
            if let reloaded = workspaceProject(matchingPath: localPath) {
                selectProject(reloaded)
            } else {
                selectProject(existingProject)
            }
            setWorkspaceNotice(
                message: "Projekt był już zarejestrowany i został aktywowany.",
                isError: false
            )
            return
        }

        let projectName = name.isEmpty ? URL(fileURLWithPath: localPath).lastPathComponent : name
        let registration = projectRegistryService(for: preferredStorageProfile)
            .registerProject(name: projectName, localPath: localPath)
        guard registration.result.isSuccess else {
            setWorkspaceNotice(
                message: errorMessage(from: registration.result, fallback: "Nie udało się zarejestrować projektu."),
                isError: true
            )
            return
        }

        refreshWorkspace(retainingSelection: false)
        if let reloaded = workspaceProject(matchingPath: localPath) {
            selectProject(reloaded)
        }
    }

    func createIdea() {
        guard let project = selectedProject else {
            return
        }

        let registry = ideaRegistryService(for: project.storageProfile)
        registry.selectActiveProject(id: project.record.id)

        let description = newIdeaDraft.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let result = registry.createIdea(
            title: newIdeaDraft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description
        )

        guard result.result.isSuccess,
              let createdIdeaID = result.createdIdeaID,
              let idea = registry.idea(by: createdIdeaID)
        else {
            setWorkspaceNotice(
                message: errorMessage(from: result.result, fallback: "Nie udało się utworzyć idei."),
                isError: true
            )
            return
        }

        showCreateIdeaSheet = false
        selectIdea(idea, in: project)
    }

    func workspaceProject(matchingPath localPath: String) -> WorkspaceProject? {
        let normalizedPath = normalized(localPath)
        return wrappedProjects().first { normalized($0.record.localPath) == normalizedPath }
    }

    func normalized(_ path: String) -> String {
        URL(fileURLWithPath: path).standardizedFileURL.path
    }

    func projectRegistryService(for profile: StorageProfile) -> any ProjectRegistryContract {
        switch profile {
        case .fileAI:
            return fileAIProjectRegistryService
        case .sqlbase:
            return sqlbaseProjectRegistryService
        }
    }

    func ideaRegistryService(for profile: StorageProfile) -> IdeaRegistryContract {
        switch profile {
        case .fileAI:
            return fileAIIdeaRegistryService
        case .sqlbase:
            return sqlbaseIdeaRegistryService
        }
    }

    func setWorkspaceNotice(message: String, isError: Bool) {
        workspaceNotice = WorkspaceNotice(message: message, isError: isError)
    }

    func errorMessage(from result: RegistryOperationResult, fallback: String) -> String {
        switch result {
        case .success:
            return fallback
        case let .failure(reason):
            return reason.message
        }
    }
}
