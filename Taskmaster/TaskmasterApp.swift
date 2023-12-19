import SwiftUI
import SwiftData

@main
struct TaskmasterApp: App {
    
    @StateObject var settings: SettingsStore = SettingsStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DisplayTaskListPage()
            }
            .environmentObject(settings)
        }
        .modelContainer(for: TaskItem.self)
    }
}
