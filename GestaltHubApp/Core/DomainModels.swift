import Foundation

enum Platform: String, Codable, Sendable {
    case iOS
    case iPadOS
}

struct DeviceContext: Codable, Equatable, Sendable {
    let platform: Platform
    let modelIdentifier: String?
    let operatingSystemVersion: String
    let buildNumber: String?
    let hardwareFamily: String?
    let regionCode: String?
    let isReadOnlyEnvironment: Bool
}

enum FeatureValueType: String, Codable, Sendable {
    case boolean
    case integer
    case string
    case array
    case dictionary
    case opaque
}

enum CompatibilityStatus: String, Codable, Sendable {
    case supported
    case conditional
    case unsupported
    case unknown
    case blocked
}

enum RiskLevel: String, Codable, Sendable {
    case informational
    case low
    case medium
    case high
    case critical
}

enum WritePolicy: String, Codable, Sendable {
    case readOnly
    case plannedOnly
    case backendDependent
    case unavailable
}

struct FeatureDefinition: Codable, Identifiable, Sendable {
    let id: String
    let key: String
    let displayName: String
    let summary: String
    let valueType: FeatureValueType
    let platformScope: Set<Platform>
    let riskLevel: RiskLevel
    let writePolicy: WritePolicy
}

struct CompatibilityResult: Codable, Sendable {
    let status: CompatibilityStatus
    let reasons: [String]
    let confidence: String
    let databaseVersion: String
}

struct ModificationPlan: Codable, Identifiable, Sendable {
    let id: UUID
    let featureID: String
    let proposedValueDescription: String
    let compatibility: CompatibilityResult
    let requiresBackup: Bool
    let rollbackDescription: String
}

struct BackupReference: Codable, Sendable {
    let id: UUID
    let createdAt: Date
    let integrityDigest: String
}
