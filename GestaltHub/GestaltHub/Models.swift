/*
 * GestaltHub
 *
 * Copyright (C) 2026 thanking157
 *
 * Original code and integration by thanking157.
 */
import Foundation

enum KeyCategory: String, CaseIterable, Identifiable {
    case display = "顯示"
    case device = "關於此裝置"
    case ipad = "iPad功能"
    case intelligence = "Apple 智慧功能"
    case region = "地區"
    case camera = "相機"
    case audio = "音訊"
    case connectivity = "連線"
    case system = "系統"
    case advanced = "進階／未分類"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .display: "display"
        case .device: "iphone"
        case .ipad: "ipad"
        case .intelligence: "apple.intelligence"
        case .region: "globe.asia.australia"
        case .camera: "camera"
        case .audio: "speaker.wave.2"
        case .connectivity: "antenna.radiowaves.left.and.right"
        case .system: "gearshape"
        case .advanced: "slider.horizontal.3"
        }
    }
}

enum GestaltValueKind: String, Codable { case boolean, integer, string, choice, dictionary, array, unknown }
enum KeyRisk: String, Codable { case normal, caution, experimental }

struct GestaltKey: Identifiable, Hashable {
    let id: String
    let name: String
    let explanation: String
    let category: KeyCategory
    let kind: GestaltValueKind
    let supportedOS: String
    let risk: KeyRisk
    let values: [String]
    let groupedKeys: [String]

    init(_ id: String, _ name: String, _ explanation: String, category: KeyCategory, kind: GestaltValueKind = .boolean, os: String = "依裝置與系統版本", risk: KeyRisk = .normal, values: [String] = [], groupedKeys: [String] = []) {
        self.id = id; self.name = name; self.explanation = explanation; self.category = category
        self.kind = kind; self.supportedOS = os; self.risk = risk; self.values = values
        self.groupedKeys = groupedKeys.isEmpty ? [id] : groupedKeys
    }
}

struct BackupRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let createdAt: Date
    let reason: String
    let fileName: String
}

struct ActivityLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    let message: String
    let level: Level
    enum Level: String, Codable { case info, success, warning, error }
}

enum ProviderState: Equatable { case idle, reading, ready, unavailable(String), writing }
