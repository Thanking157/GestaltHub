import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Environment") {
                    Label("Device Inspector", systemImage: "iphone")
                    Label("Feature Database", systemImage: "list.bullet.rectangle")
                }

                Section("Planning") {
                    Label("Modification Planner", systemImage: "checklist")
                    Label("Backups and Restore", systemImage: "externaldrive")
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

                Section("Advanced") {
                    Label("Expert Editor", systemImage: "slider.horizontal.3")
                }
            }
            .navigationTitle("GestaltHub")
        }
    }
}

#Preview {
    ContentView()
}
