/*
 * GestaltHub
 *
 * Copyright (C) 2026 thanking157
 *
 * Original code and integration by thanking157.
 */
import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("首頁", systemImage: "house") }
            CatalogView()
                .tabItem { Label("MobileGestalt", systemImage: "slider.horizontal.3") }
            BackupsView()
                .tabItem { Label("備份", systemImage: "archivebox") }
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: GestaltStore
    @State private var showApplyAlert = false
    @State private var showExperimentalWarning = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "iphone")
                            .font(.system(size: 30)).foregroundStyle(.blue)
                            .frame(width: 48, height: 48).background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(UIDevice.current.name).font(.headline)
                            Text("\(UIDevice.current.model) · \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)").foregroundStyle(.secondary).font(.subheadline)
                        }
                    }.padding(.vertical, 4)
                    statusRow("MobileGestalt", stateText, stateColor)
                    statusRow("最近修改", store.lastModified?.formatted(date: .abbreviated, time: .shortened) ?? "尚未修改", .secondary)
                    statusRow("備份", store.backups.isEmpty ? "尚無備份" : "\(store.backups.count) 份可用", store.backups.isEmpty ? .secondary : .green)
                } header: { Text("裝置") }

                Section {
                    NavigationLink { CatalogView() } label: {
                        Label("管理 MobileGestalt", systemImage: "slider.horizontal.3")
                    }
                    Button { Task { await store.read() } } label: {
                        Label("讀取裝置 MobileGestalt", systemImage: "arrow.clockwise")
                    }
                    .disabled(store.providerState == .reading || store.providerState == .writing)
                    Button { requestApply() } label: {
                        Label("套用已暫存的修改", systemImage: "checkmark.circle")
                    }
                    .disabled(!store.isLoaded || store.providerState == .writing)
                } header: { Text("MobileGestalt") }

                Section {
                    if store.logs.isEmpty { Text("尚無活動紀錄").foregroundStyle(.secondary) }
                    ForEach(store.logs.prefix(3)) { log in LogRow(log: log) }
                    NavigationLink("查看所有紀錄") { LogsView() }
                } header: { Text("Logs") }
            }
            .navigationTitle("GestaltHub")
            .alert("套用 MobileGestalt 修改?", isPresented: $showApplyAlert) {
                Button("取消", role: .cancel) {}
                Button("套用", role: .destructive) { Task { try? await store.apply() } }
            } message: { Text("套用前會自動建立備份，完成後會驗證寫入內容。部分變更需要重新啟動裝置。") }
            .sheet(isPresented: $showExperimentalWarning) {
                ExperimentalApplySheet {
                    showExperimentalWarning = false
                    Task { try? await store.apply() }
                } cancel: { showExperimentalWarning = false }
                .presentationDetents([.height(260)])
            }
        }
    }

    private var stateText: String {
        switch store.providerState { case .idle: "尚未讀取"; case .reading: "讀取中"; case .ready: "已讀取"; case .writing: "寫入中"; case .unavailable: "無法存取" }
    }
    private var stateColor: Color { switch store.providerState { case .ready: .green; case .unavailable: .red; case .reading, .writing: .orange; case .idle: .secondary } }
    private func statusRow(_ title: String, _ value: String, _ color: Color) -> some View { HStack { Text(title); Spacer(); Text(value).foregroundStyle(color).multilineTextAlignment(.trailing) } }
    private func requestApply() {
        if store.hasExperimentalChanges { showExperimentalWarning = true }
        else { showApplyAlert = true }
    }
}

struct ExperimentalApplySheet: View {
    let apply: () -> Void
    let cancel: () -> Void
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundStyle(.orange)
            Text("真要套用實驗功能嗎?").font(.headline)
            Text("實驗功能可能無法正常運作甚至造成系統問題嚴重可變成磚確認已有備份後再繼續。")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            HStack(spacing: 12) {
                Button("算了..", action: cancel).buttonStyle(.borderedProminent).tint(.blue).frame(maxWidth: .infinity)
                Button(action: apply) {
                    Text("我知道我在做什麼>:(").foregroundStyle(.black).frame(maxWidth: .infinity).padding(.vertical, 8)
                }
                .background(.red, in: Capsule())
                .frame(maxWidth: .infinity)
            }.padding(.horizontal)
        }.padding(.top, 20)
    }
}

struct CatalogView: View {
    @EnvironmentObject private var store: GestaltStore
    @State private var query = ""
    private var matchingKeys: [GestaltKey] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return KeyCatalog.all }
        return KeyCatalog.all.filter { $0.name.localizedCaseInsensitiveContains(trimmed) || $0.id.localizedCaseInsensitiveContains(trimmed) || $0.explanation.localizedCaseInsensitiveContains(trimmed) }
    }
    var body: some View {
        NavigationStack {
            List {
                if !store.isLoaded {
                    Section { ContentUnavailableView("先讀取 MobileGestalt", systemImage: "arrow.clockwise", description: Text("讀取後才能查看目前值及暫存修改:3")) }
                }
                if query.isEmpty {
                    Section("功能分類") {
                        ForEach(KeyCategory.allCases) { category in
                            let count = KeyCatalog.all.filter { $0.category == category }.count
                            if count > 0 {
                                NavigationLink { CategoryView(category: category) } label: {
                                    Label { VStack(alignment: .leading, spacing: 2) { Text(category.rawValue); Text("\(count) 個功能").font(.caption).foregroundStyle(.secondary) } } icon: { Image(systemName: category.symbol).foregroundStyle(.blue) }
                                }
                            }
                        }
                    }
                } else {
                    Section("搜尋結果") { ForEach(matchingKeys) { FeatureControl(key: $0) } }
                }
            }
            .searchable(text: $query, prompt: "搜尋名稱、key 或說明")
            .navigationTitle("MobileGestalt")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { Task { await store.read() } } label: { Image(systemName: "arrow.clockwise") } } }
        }
    }
}

struct CategoryView: View {
    @EnvironmentObject private var store: GestaltStore
    let category: KeyCategory
    private var keys: [GestaltKey] { KeyCatalog.all.filter { $0.category == category } }
    var body: some View {
        List {
            Section { ForEach(keys) { FeatureControl(key: $0) } }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureControl: View {
    @EnvironmentObject private var store: GestaltStore
    let key: GestaltKey
    @State private var selection = ""
    @State private var modelName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if key.risk == .experimental {
                Label("這是個實驗功能~", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2).foregroundStyle(.orange)
            }
        if key.id == "gestalthub.artworkSubtype" {
            Picker("動態島類型", selection: $selection) {
                Text("原始設定").tag("")
            ForEach(artworkTypes.keys.sorted(), id: \.self) { Text(artworkTypes[$0]!).tag($0) }
            }
            .onAppear { selection = store.artworkValue("ArtworkDeviceSubType") }
            .onChange(of: selection) { _, value in if let type = Int(value) { store.setArtwork(NSNumber(value: type), field: "ArtworkDeviceSubType") } }
        } else if key.id == "gestalthub.artworkName" {
            HStack {
                TextField("機型名稱", text: $modelName)
                    .onAppear { modelName = store.artworkValue("ArtworkDeviceProductDescription") }
                Button("儲存") { store.setArtwork(modelName, field: "ArtworkDeviceProductDescription") }
                    .disabled(modelName.isEmpty)
            }
        } else if key.id == "h63QSdBCiT/z0WU6rdQv6Q" {
            Picker("地區", selection: $selection) {
                Text("原始設定").tag("")
                ForEach(regionNames, id: \.self) { Text($0).tag($0) }
            }
            .onAppear { selection = store.regionSelection() }
            .onChange(of: selection) { _, value in if !value.isEmpty { store.setRegion(value) } }
        } else if key.id == "gestalthub.ipadosMode" {
            Toggle("iPadOS Mode", isOn: Binding(get: { store.isEnabled(key) }, set: { _ = store.setIPadOSMode($0) }))
        } else if key.id == "9MZ5AdH43csAUajl/dU+IQ" {
            Toggle("iPad App 相容性", isOn: Binding(get: { store.value(for: key) != "未設定" }, set: { store.setValue($0 ? [NSNumber(value: 1), NSNumber(value: 2)] : [], for: key) }))
        } else if key.id == "UIParallaxCapability" {
            Toggle("關閉壁紙視差", isOn: Binding(get: { (store.document?.cacheExtra[key.id] as? NSNumber)?.intValue == 0 }, set: { store.setValue(NSNumber(value: $0 ? 0 : 1), for: key) }))
        } else if key.kind == .boolean {
            Toggle(key.name, isOn: Binding(get: { store.isEnabled(key) }, set: { store.setEnabled($0, for: key) }))
        } else if key.kind == .choice || (key.kind == .integer && !key.values.isEmpty) {
            Picker(key.name, selection: $selection) {
                Text("原始設定").tag("")
                ForEach(key.values, id: \.self) { Text(optionTitle($0)).tag($0) }
            }
            .onAppear { selection = store.value(for: key) == "未設定" ? "" : store.value(for: key) }
            .onChange(of: selection) { _, value in
                if !value.isEmpty { store.setValue(key.kind == .integer ? NSNumber(value: Int(value) ?? 0) : value, for: key) }
            }
        } else {
            LabeledContent(key.name, value: store.value(for: key))
        }
        }
    }
    private let artworkTypes = ["2436": "iPhone 14 Pro (2436)", "2796": "iPhone 14 Pro Max (2796)", "2976": "iPhone 15 Pro Max (2976)", "2622": "iPhone 16 Pro (2622)", "2868": "iPhone 16 Pro Max (2868)", "2736": "iPhone Air (2736)", "2670": "iPhone 18 Pro Max (2670)"]
    private let regionNames = ["美國", "香港", "日本", "台灣", "英國", "加拿大"]
    private func optionTitle(_ raw: String) -> String {
        guard key.id == "a3n5T9sFtlyQ74NEp9ESxg" else { return raw }
        return switch raw {
        case "0": "傳統模式 (0)"
        case "1": "只有發光動畫(1)"
        case "2": "完整Siri AI 需偽裝型號 (2)"
        default: raw
        }
    }
}
