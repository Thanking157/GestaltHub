/*
 * GestaltHub
 *
 * Copyright (C) 2026 thanking157
 *
 * Original code and integration by thanking157.
 */
import Foundation
import Darwin
enum GestaltPath {
    nonisolated static let cache = URL(fileURLWithPath: "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
    nonisolated static let documents = URL.documentsDirectory.appendingPathComponent("GestaltHub", isDirectory: true)
    nonisolated static let backups = documents.appendingPathComponent("Backups", isDirectory: true)
    nonisolated static let journal = documents.appendingPathComponent("backups.json")
}

enum GestaltProviderError: LocalizedError {
    case invalidPlist, missingCacheExtra, stale, writeFailed(String), verificationFailed
    var errorDescription: String? {
        switch self {
        case .invalidPlist: "MobileGestalt plist 格式無法辨識。"
        case .missingCacheExtra: "此 plist 沒有 CacheExtra 字典。"
        case .stale: "MobileGestalt 在讀取後已變更。請重新讀取再套用修改。"
        case .writeFailed(let message): "無法寫入 MobileGestalt：\(message)"
        case .verificationFailed: "寫入後驗證失敗；已嘗試回復原始內容。"
        }
    }
}

struct GestaltDocument {
    private(set) var root: [String: Any]

    init(data: Data) throws {
        guard let object = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else { throw GestaltProviderError.invalidPlist }
        guard object["CacheExtra"] is [String: Any] else { throw GestaltProviderError.missingCacheExtra }
        root = object
    }

    var cacheExtra: [String: Any] { root["CacheExtra"] as? [String: Any] ?? [:] }
    mutating func set(_ value: Any, for keys: [String]) {
        var extra = cacheExtra
        keys.forEach { extra[$0] = value }
        root["CacheExtra"] = extra
    }
    mutating func remove(keys: [String]) {
        var extra = cacheExtra
        keys.forEach { extra.removeValue(forKey: $0) }
        root["CacheExtra"] = extra
    }
    mutating func setCacheData(_ data: Data) { root["CacheData"] = data }
    func data() throws -> Data {
        try PropertyListSerialization.data(fromPropertyList: root, format: .binary, options: 0)
    }
}

protocol MobileGestaltProviding {
    func prepareAccess() -> String?
    func read() throws -> Data
    func writeVerified(_ data: Data, expectedOriginal: Data) throws
}

struct ErosionCompatibleProvider: MobileGestaltProviding {
    let url: URL
    nonisolated init(url: URL = GestaltPath.cache) { self.url = url }
    func prepareAccess() -> String? { GestaltAccess.shared.prepare(for: url.deletingLastPathComponent()) }
    func read() throws -> Data { try Data(contentsOf: url) }

    func writeVerified(_ data: Data, expectedOriginal: Data) throws {
        let current = try read()
        guard current == expectedOriginal else { throw GestaltProviderError.stale }
        do {
            try directWrite(data)
        } catch {
            do {
                try descriptorWrite(data, rollback: expectedOriginal)
            } catch {
                try temporaryReplacement(data)
            }
        }
        guard try read() == data else { throw GestaltProviderError.verificationFailed }
    }

    private func directWrite(_ data: Data) throws {
        do { try data.write(to: url) }
        catch { throw GestaltProviderError.writeFailed(error.localizedDescription) }
    }

    private func temporaryReplacement(_ data: Data) throws {
        let temporary = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).\(UUID().uuidString).tmp")
        do {
            try data.write(to: temporary, options: [.withoutOverwriting])
            if FileManager.default.fileExists(atPath: url.path) {
                _ = try FileManager.default.replaceItemAt(url, withItemAt: temporary)
            } else { try FileManager.default.moveItem(at: temporary, to: url) }
        } catch { throw GestaltProviderError.writeFailed(error.localizedDescription) }
    }

    private func descriptorWrite(_ data: Data, rollback original: Data) throws {
        let descriptor = url.path.withCString { open($0, O_RDWR | O_CLOEXEC | O_NOFOLLOW) }
        guard descriptor >= 0 else { throw GestaltProviderError.writeFailed(String(cString: strerror(errno))) }
        defer { close(descriptor) }
        do {
            guard ftruncate(descriptor, 0) == 0 else { throw GestaltProviderError.writeFailed("truncate") }
            try writeAll(descriptor, data)
            guard fsync(descriptor) == 0 else { throw GestaltProviderError.writeFailed("sync") }
        } catch {
            _ = ftruncate(descriptor, 0)
            _ = lseek(descriptor, 0, SEEK_SET)
            try? writeAll(descriptor, original)
            _ = fsync(descriptor)
            throw error
        }
    }

    private func writeAll(_ descriptor: Int32, _ data: Data) throws {
        try data.withUnsafeBytes { bytes in
            guard let base = bytes.baseAddress else { return }
            var offset = 0
            while offset < data.count {
                let result = Darwin.write(descriptor, base.advanced(by: offset), data.count - offset)
                if result > 0 { offset += result; continue }
                if result < 0 && errno == EINTR { continue }
                throw GestaltProviderError.writeFailed(String(cString: strerror(errno)))
            }
        }
    }
}
