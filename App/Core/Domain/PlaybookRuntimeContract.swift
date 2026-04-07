import Foundation

protocol PlaybookRuntimeContract {
    func runNewProject(_ request: PlaybookNewProjectRequest) -> PlaybookNewProjectResult
    func addIdea(_ request: PlaybookAddIdeaRequest) -> PlaybookAddIdeaResult
    func summarizeRuntime(at projectRootPath: String) -> PlaybookRuntimeSummary
}
