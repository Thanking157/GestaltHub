/*
 * GestaltHub
 *
 * Copyright (C) 2026 thanking157
 *
 * Original code and integration by thanking157.
 */
import SwiftUI

struct BackupsView: View {
    @EnvironmentObject private var store: GestaltStore
    @State private var restoreTarget: BackupRecord?
    var body: some View {
        NavigationStack {
            List {
                Section { Label("每次套用前GestaltHub都會保存完整修改前的plist還原也會先驗證檔案結構與裝置目前版本:D", systemImage: "shield.lefthalf.filled").font(.subheadline).foregroundStyle(.secondary) }
                if store.backups.isEmpty { ContentUnavailableView("空空的沒備份D:", systemImage: "archivebox", description: Text("套用修改後會有備份會出現在這裡:D")) }
                ForEach(store.backups) { backup in
                    Button { restoreTarget = backup } label: {
                        VStack(alignment: .leading, spacing: 3) { Text(backup.reason).foregroundStyle(.primary); Text(backup.createdAt.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary) }
                    }
                }
            }.navigationTitle("備份")
            .alert("還原此備份?", isPresented: Binding(get: { restoreTarget != nil }, set: { if !$0 { restoreTarget = nil } })) {
                Button("取消", role: .cancel) { restoreTarget = nil }
                Button("還原", role: .destructive) { if let backup = restoreTarget { Task { try? await store.restore(backup) }; restoreTarget = nil } }
            } message: { Text("您已恢復備份:D 請重新啟動裝置效果就會有了:3") }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("使用方式w") {
                    Label("先讀取->再修改->最後套用:3", systemImage: "1.circle")
                    Label("套用前自動備份寫入後會重新讀取驗證:D", systemImage: "2.circle")
                    Label("部分變更需重新啟動裝置才能生效<0^0>!", systemImage: "3.circle")
                }
                Section("開發者／診斷") { NavigationLink { DiagnosticsView() } label: { Label("診斷紀錄", systemImage: "stethoscope") } }
                Section { NavigationLink { AcknowledgementsView() } label: { Label("鳴謝", systemImage: "heart") } }
                Section { LabeledContent("GestaltHub", value: "1.0"); Text("一個MobileGestalt 修改器 for iOS & iPadOS") .font(.footnote).foregroundStyle(.secondary) }
            }.navigationTitle("設定")
        }
    }
}

struct AcknowledgementsView: View {
    var body: some View {
        List {
            Section("特別感謝>:3") {
                CreditLink("forcequitOS / worse_query", "https://github.com/forcequitOS/worse_query")
                CreditLink("thanking157 / GestaltHub", "https://github.com/Thanking157/GestaltHub")
            }
            Section("感謝:D") {
                CreditLink("jailbreakdotparty / Erosion", "https://github.com/jailbreakdotparty/Erosion")
                CreditLink("leminlimez / Nugget", "https://github.com/leminlimez/Nugget")
                CreditLink("huami1314 / GestaltX", "https://github.com/huami1314/GestaltX")
            }
        }
        .navigationTitle("鳴謝")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CreditLink: View {
    let title: String
    let address: String
    init(_ title: String, _ address: String) { self.title = title; self.address = address }
    var body: some View {
        Link(destination: URL(string: address)!) {
            HStack { Text(title).foregroundStyle(.primary); Spacer(); Image(systemName: "arrow.up.right.square").foregroundStyle(.blue) }
        }
    }
}

struct DiagnosticsView: View {
    @EnvironmentObject private var store: GestaltStore
    var body: some View {
        List {
            Section("MobileGestalt") {
                LabeledContent("讀取狀態", value: status)
                LabeledContent("目前欄位", value: "\(store.document?.cacheExtra.count ?? 0)")
                LabeledContent("備份數量", value: "\(store.backups.count)")
            }
            Section("說明") { Text("診斷資訊只放在此頁用於確認讀取備份與驗證流程是否正常w") .font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("診斷").navigationBarTitleDisplayMode(.inline)
    }
    private var status: String { switch store.providerState { case .idle: "未讀取"; case .reading: "讀取中"; case .ready: "可用"; case .writing: "寫入中"; case .unavailable(let reason): reason } }
}

struct LogsView: View {
    @EnvironmentObject private var store: GestaltStore
    var body: some View { List { if store.logs.isEmpty { ContentUnavailableView("Nono紀錄", systemImage: "text.line.first.and.arrowtriangle.forward") }; ForEach(store.logs) { LogRow(log: $0) } }.navigationTitle("Logs").navigationBarTitleDisplayMode(.inline) }
}

struct LogRow: View {
    let log: ActivityLog
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol).foregroundStyle(color).frame(width: 18)
            VStack(alignment: .leading, spacing: 3) { Text(log.message); Text(log.date.formatted(date: .omitted, time: .standard)).font(.caption).foregroundStyle(.secondary) }
        }
    }
    private var symbol: String { switch log.level { case .info: "info.circle"; case .success: "checkmark.circle"; case .warning: "exclamationmark.triangle"; case .error: "xmark.circle" } }
    private var color: Color { switch log.level { case .info: .blue; case .success: .green; case .warning: .orange; case .error: .red } }
}
