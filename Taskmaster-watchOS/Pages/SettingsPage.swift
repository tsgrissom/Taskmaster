import SwiftUI
import SwiftData

struct SettingsPage: View {
    
    @Environment(\.modelContext)
    private var context
    
    @Query
    private var tasks: [TaskItem]
    
    var body: some View {
        ScrollView {
            VStack {
                rowTasksCount
                    .padding(.top)
            }
        }
        .navigationTitle("Settings")
    }
    
    private var rowTasksCount: some View {
        let count = StringUtilities.createCountString("task", arr: tasks, capitalize: false, overrideEmpty: "tasks")
        return HStack {
            Button("Clear \(count)") {
                for task in tasks {
                    context.delete(task)
                }
            }
            .tint(.red)
            .disabled(tasks.count == 0)
//            .frame(width: 75)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsPage()
    }
}
