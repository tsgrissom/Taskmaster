import SwiftUI
import SwiftData

@main
struct TaskmasterApp: App {
    
    @StateObject var settings: SettingsStore = SettingsStore()
    
    private func createModelContainer() -> ModelContainer {
        let groupName = "group.io.github.tsgrissom.taskmaster"
        let schema = Schema([TaskItem.self])
        let modelConf = ModelConfiguration(
            "TaskmasterModelConfiguration",
            schema: schema,
            groupContainer: ModelConfiguration.GroupContainer.identifier(groupName)
        )
        return try! ModelContainer(for: TaskItem.self, configurations: modelConf)
    }
    
    public var body: some Scene {
        WindowGroup {
            NavigationStack {
                DisplayTaskListPage()
            }
            .environmentObject(settings)
        }
        .modelContainer(createModelContainer())
    }
}
