import Foundation

protocol ArtifactSyncContract {
    func synchronize(_ request: ArtifactSyncRequest) -> ArtifactSyncResult
}
