import Foundation

struct CompatibilityEngine: CompatibilityEvaluating {
    let databaseVersion: String

    func evaluate(
        feature: FeatureDefinition,
        on device: DeviceContext,
        proposedValueDescription: String? = nil
    ) -> CompatibilityResult {
        guard feature.platformScope.contains(device.platform) else {
            return CompatibilityResult(
                status: .unsupported,
                reasons: ["The feature is not scoped for this platform."],
                confidence: "documented",
                databaseVersion: databaseVersion
            )
        }

        if device.isReadOnlyEnvironment && feature.writePolicy != .readOnly {
            return CompatibilityResult(
                status: .conditional,
                reasons: ["This environment is read-only; no write backend is available."],
                confidence: "observed",
                databaseVersion: databaseVersion
            )
        }

        guard proposedValueDescription != nil || feature.writePolicy == .readOnly else {
            return CompatibilityResult(
                status: .blocked,
                reasons: ["A proposed value is required before planning a change."],
                confidence: "observed",
                databaseVersion: databaseVersion
            )
        }

        return CompatibilityResult(
            status: .unknown,
            reasons: ["No authoritative compatibility rule has been recorded for this feature."],
            confidence: "unknown",
            databaseVersion: databaseVersion
        )
    }
}
