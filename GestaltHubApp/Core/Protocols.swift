import Foundation

protocol DeviceDetecting: Sendable {
    func detect() async throws -> DeviceContext
}

protocol FeatureRepository: Sendable {
    func feature(id: String) async throws -> FeatureDefinition?
    func allFeatures() async throws -> [FeatureDefinition]
}

protocol CompatibilityEvaluating: Sendable {
    func evaluate(
        feature: FeatureDefinition,
        on device: DeviceContext,
        proposedValueDescription: String?
    ) -> CompatibilityResult
}

protocol ModificationPlanning: Sendable {
    func makePlan(
        feature: FeatureDefinition,
        device: DeviceContext,
        proposedValueDescription: String?
    ) async throws -> ModificationPlan
}

protocol BackupManaging: Sendable {
    func createBackup() async throws -> BackupReference
    func restore(_ reference: BackupReference) async throws
}

struct BackendCapabilities: Sendable {
    let identifier: String
    let isReadOnly: Bool
    let supportsBackup: Bool
    let supportedPlatforms: Set<Platform>
}

protocol WriteBackend: Sendable {
    func capabilities() async -> BackendCapabilities
    func apply(plan: ModificationPlan) async throws
}
