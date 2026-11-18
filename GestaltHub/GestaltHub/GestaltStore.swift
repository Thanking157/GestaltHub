/*
 * GestaltHub
 *
 * Copyright (C) 2026 thanking157
 *
 * Original code and integration by thanking157.
 */
import Foundation
import Combine

@MainActor
final class GestaltStore: ObservableObject {
    @Published private(set) var document: GestaltDocument?
    @Published private(set) var originalData: Data?
    @Published private(set) var providerState: ProviderState = .idle
    @Published private(set) var logs: [ActivityLog] = []
    @Published private(set) var backups: [BackupRecord] = []
    @Published private(set) var stagedFeatureIDs = Set<String>()
    @Published var lastModified: Date?

    private let provider: any MobileGestaltProviding
    init(provider: any MobileGestaltProviding = ErosionCompatibleProvider()) {
        self.provider = provider
        loadJournal()
    }

    var isLoaded: Bool { document != nil && originalData != nil }
    var pendingCount: Int {
        guard let document else { return 0 }
        return document.cacheExtra.count
    }

    func read() async {
        providerState = .reading
        append("正在讀取裝置 MobileGestalt…", .info)
        do {
            if let accessError = provider.prepareAccess() {
                append("MobileGestalt 存取：\(accessError)", .warning)
            }
            let bytes = try provider.read()
            document = try GestaltDocument(data: bytes)
            originalData = bytes
            stagedFeatureIDs.removeAll()
            providerState = .ready
            append("已讀取 MobileGestalt（\(bytes.count.formatted()) bytes）:D", .success)
        } catch {
            providerState = .unavailable(error.localizedDescription)
            append(error.localizedDescription, .error)
        }
    }

    func isEnabled(_ key: GestaltKey) -> Bool {
        guard let value = document?.cacheExtra[key.groupedKeys[0]] else { return false }
        if let number = value as? NSNumber { return number.boolValue }
        if let integer = value as? Int { return integer == 1 }
        return false
    }

    func value(for key: GestaltKey) -> String {
        guard let value = document?.cacheExtra[key.id] else { return "未設定" }
        if let data = value as? Data { return "Data（\(data.count) bytes）" }
        return String(describing: value)
    }

    func setEnabled(_ enabled: Bool, for key: GestaltKey) {
        guard var document else { return }
        enabled ? document.set(NSNumber(value: true), for: key.groupedKeys) : document.remove(keys: key.groupedKeys)
        self.document = document
        stagedFeatureIDs.insert(key.id)
        lastModified = Date()
        append("已暫存：\(key.name)\(enabled ? "開啟" : "還原")", .info)
    }

    func setValue(_ value: Any, for key: GestaltKey) {
        guard var document else { return }
        document.set(value, for: key.groupedKeys)
        self.document = document; lastModified = Date()
        stagedFeatureIDs.insert(key.id)
        append("已暫存：\(key.name)", .info)
    }

    func artworkValue(_ field: String) -> String {
        let artwork = document?.cacheExtra["oPeik/9e8lQWMszEjbPzng"] as? [String: Any]
        return artwork?[field].map { String(describing: $0) } ?? ""
    }

    func setArtwork(_ value: Any, field: String) {
        guard var document else { return }
        let key = "oPeik/9e8lQWMszEjbPzng"
        var artwork = document.cacheExtra[key] as? [String: Any] ?? [:]
        artwork[field] = value
        document.set(artwork, for: [key])
        self.document = document; lastModified = Date()
        append("已暫存：\(field)", .info)
    }

    func setRegion(_ selection: String) {
        let values: [String: (String, String)] = ["美國": ("LL", "LL/A"), "香港": ("ZA", "ZA/A"), "日本": ("J", "J/A"), "台灣": ("TA", "TA/A"), "英國": ("B", "B/A"), "加拿大": ("C", "C/A")]
        guard var document, let value = values[selection] else { return }
        document.set(value.0, for: ["h63QSdBCiT/z0WU6rdQv6Q"])
        document.set(value.1, for: ["zHeENZu+wbg7PUprwNwBWg", "yK+xavymRGZ3xWc1tb8XDg"])
        self.document = document; lastModified = Date()
        append("已暫存：地區 \(selection)", .info)
    }

    func regionSelection() -> String {
        let code = document?.cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] as? String
        return ["LL": "美國", "ZA": "香港", "J": "日本", "TA": "台灣", "B": "英國", "C": "加拿大"][code ?? ""] ?? ""
    }

    /// Erosion's iPadOS mode patch: the capability flags are paired with a
    /// validated CacheData byte adjustment. The layout check intentionally
    /// refuses only an unknown binary layout; it never hides the UI option.
    func setIPadOSMode(_ enabled: Bool) -> Bool {
        guard var document, var cacheData = document.root["CacheData"] as? Data else {
            append("無法修改 iPadOS Mode：缺少 CacheData。", .error)
            return false
        }
        guard updateIPadCacheData(&cacheData, enabled: enabled) else {
            append("無法修改 iPadOS Mode：這個 CacheData 版面尚未支援。", .error)
            return false
        }
        let keys = ["uKc7FPnEO++lVhHWHFlGbQ", "mG0AnH/Vy1veoqoLRAIgTA", "UCG5MkVahJxG1YULbbd5Bg", "ZYqko/XM5zD3XBfN5RmaXA", "nVh/gwNpy7Jv1NOk00CMrw", "qeaj75wk3HF4DwQ8qbIi7g"]
        enabled ? document.set(NSNumber(value: true), for: keys) : document.remove(keys: keys)
        document.setCacheData(cacheData)
        self.document = document; lastModified = Date()
        stagedFeatureIDs.insert("gestalthub.ipadosMode")
        append("已暫存：iPadOS Mode\(enabled ? "開啟" : "還原")", .info)
        return true
    }

    private func updateIPadCacheData(_ data: inout Data, enabled: Bool) -> Bool {
        let hexString = data.map { String(format: "%02x", $0) }.joined()
        var hex = Array(hexString)
        let sliceStart = 1616
        let sliceLength = 200
        guard hex.count > sliceStart else { return false }
        let end = min(hex.count, sliceStart + sliceLength)
        let slice = String(hex[sliceStart..<end])
        guard let regex = try? NSRegularExpression(pattern: "0+(?:5555)*([0-9a-f]{4})") else { return false }
        let range = NSRange(slice.startIndex..<slice.endIndex, in: slice)
        var target: Int?
        regex.enumerateMatches(in: slice, range: range) { match, _, stop in
            guard let match, let capture = Range(match.range(at: 1), in: slice) else { return }
            if slice[capture].filter({ $0 != "0" }).count >= 3 {
                target = sliceStart + slice.distance(from: slice.startIndex, to: capture.lowerBound)
                stop.pointee = true
            }
        }
        guard let offset = target else { return false }
        let left = offset - 67, right = offset + 13
        guard left > 0, right < hex.count - 1,
              ["1", "3"].contains(String(hex[left])), hex[left - 1] == "0", hex[left + 1] == "0",
              ["1", "3"].contains(String(hex[right])), hex[right - 1] == "0", hex[right + 1] == "0" else { return false }
        hex[left] = enabled ? "3" : "1"
        let updated = String(hex)
        var bytes = Data(); var index = updated.startIndex
        while index < updated.endIndex {
            let next = updated.index(index, offsetBy: 2)
            guard let byte = UInt8(updated[index..<next], radix: 16) else { return false }
            bytes.append(byte); index = next
        }
        data = bytes; return true
    }

    func apply() async throws {
        guard let document, let originalData else { return }
        providerState = .writing
        let changed = try document.data()
        let backup = try createBackup(data: originalData, reason: "套用修改前自動備份")
        append("已建立備份：\(backup.fileName)", .success)
        do {
            try provider.writeVerified(changed, expectedOriginal: originalData)
            self.originalData = changed
            stagedFeatureIDs.removeAll()
            providerState = .ready; lastModified = Date()
            append("已寫入並驗證 MobileGestalt :D 請重新啟動裝置讓變更完整生效>:3", .success)
        } catch {
            providerState = .ready
            append(error.localizedDescription, .error)
            throw error
        }
    }

    func restore(_ backup: BackupRecord) async throws {
        guard let originalData else { return }
        let url = GestaltPath.backups.appendingPathComponent(backup.fileName)
        let data = try Data(contentsOf: url)
        _ = try GestaltDocument(data: data)
        providerState = .writing
        try provider.writeVerified(data, expectedOriginal: originalData)
        document = try GestaltDocument(data: data); self.originalData = data
        stagedFeatureIDs.removeAll()
        providerState = .ready; lastModified = Date()
        append("已還原備份：\(backup.reason)", .success)
    }

    func append(_ message: String, _ level: ActivityLog.Level) {
        logs.insert(ActivityLog(id: UUID(), date: Date(), message: message, level: level), at: 0)
        if logs.count > 200 { logs.removeLast(logs.count - 200) }
    }

    var hasExperimentalChanges: Bool {
        KeyCatalog.all.contains { key in
            guard key.risk == .experimental, stagedFeatureIDs.contains(key.id) else { return false }
            return key.kind != .boolean || isEnabled(key)
        }
    }

    private func createBackup(data: Data, reason: String) throws -> BackupRecord {
        try FileManager.default.createDirectory(at: GestaltPath.backups, withIntermediateDirectories: true)
        let record = BackupRecord(id: UUID(), createdAt: Date(), reason: reason, fileName: "MobileGestalt-\(Int(Date().timeIntervalSince1970)).plist")
        try data.write(to: GestaltPath.backups.appendingPathComponent(record.fileName), options: .atomic)
        backups.insert(record, at: 0); saveJournal(); return record
    }
    private func loadJournal() { backups = (try? JSONDecoder().decode([BackupRecord].self, from: Data(contentsOf: GestaltPath.journal))) ?? [] }
    private func saveJournal() { try? FileManager.default.createDirectory(at: GestaltPath.documents, withIntermediateDirectories: true); try? JSONEncoder().encode(backups).write(to: GestaltPath.journal, options: .atomic) }
}
