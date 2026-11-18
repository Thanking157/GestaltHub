import Foundation

final class GestaltAccess {
    static let shared = GestaltAccess()
    private var handle: Int64?
    private init() {}

    func prepare(for directory: URL) -> String? {
        let cache = directory.appendingPathComponent("com.apple.MobileGestalt.plist")
        if FileManager.default.isWritableFile(atPath: cache.path) { return nil }
        guard let group = appGroup() else { return "找不到 GestaltHub App Group；請以包含 App Group 的簽署方式安裝。" }
        let legacy = directory.path.contains("/var/mobile/Containers/Shared/AppGroup") && ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 26
        let result = gestalthub_worse_query(directory.path, group, legacy, false)
        guard result >= 0 else { return message(for: result) }
        handle = result
        guard FileManager.default.isReadableFile(atPath: cache.path), FileManager.default.isWritableFile(atPath: cache.path) else { return "已取得存取權，但 MobileGestalt 仍不是可讀寫狀態。" }
        return nil
    }

    private func appGroup() -> String? {
        guard let task = SecTaskCreateFromSelf(nil),
              let groups = SecTaskCopyValueForEntitlement(task, "com.apple.security.application-groups" as CFString, nil) as? [String] else { return nil }
        return groups.first
    }

    private func message(for code: Int64) -> String {
        switch code {
        case -1: "無法取得 GestaltHub App Group。"
        case -2: "此系統版本無法載入 Erosion 的存取元件。"
        case -3: "無法建立 MobileGestalt 存取請求。"
        case -4: "無法建立 Erosion 存取連結。"
        case -5: "系統拒絕 MobileGestalt 存取請求。"
        case -6: "系統沒有核發 MobileGestalt 存取權。"
        case -255: "找不到 MobileGestalt 快取目錄。"
        default: "無法取得 MobileGestalt 存取權（\(code)）。"
        }
    }

    deinit { if let handle { gestalthub_worse_query_release(handle) } }
}
