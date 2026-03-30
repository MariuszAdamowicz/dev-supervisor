import Foundation

protocol GatePromptPersistenceContract {
    func persistPrompt(_ request: GatePromptPersistenceRequest) -> GatePromptPersistenceResult
}
