import Foundation

struct ReadOnlyWriteBackend: WriteBackend {
    func capabilities() async -> BackendCapabilities {
        BackendCapabilities(
            identifier: "read-only",
            isReadOnly: true,
            supportsBackup: false,
            supportedPlatforms: [.iOS, .iPadOS]
        )
    }

    func apply(plan: ModificationPlan) async throws {
        throw BackendError.readOnly
    }
}

enum BackendError: LocalizedError {
    case readOnly

    var errorDescription: String? {
        switch self {
        case .readOnly:
            return "The selected backend is read-only and cannot apply modifications."
        }
    }
}
