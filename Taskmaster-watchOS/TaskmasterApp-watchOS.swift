import SwiftUI
import SwiftData

@main
struct TaskmasterApp_WatchOS: App {
    
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
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DisplayTaskListPage()
            }
        }
        .modelContainer(createModelContainer())
    }
}

