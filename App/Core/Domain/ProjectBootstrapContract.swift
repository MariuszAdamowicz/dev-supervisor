import Foundation

protocol ProjectBootstrapContract {
    func bootstrapProject(_ input: ProjectBootstrapInput) -> ProjectBootstrapResult
    func inspectProject(at path: String) -> ProjectInspectionResult
}
