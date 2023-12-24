import SwiftUI
import SwiftData

struct SettingsPage: View {
    
    @Environment(\.modelContext)
    private var context
    
    @Query
    private var tasks: [TaskItem]
    
    @State
    private var showConfirmClearTasksDialog = false
    
    private func clearTasks() {
        for task in tasks {
            context.delete(task)
        }
    }
    
    public var body: some View {
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
                showConfirmClearTasksDialog = true
            }
            .confirmationDialog("Delete \(count)?", isPresented: $showConfirmClearTasksDialog, actions: {
                Button("Confirm") {
                    clearTasks()
                }
                Button(role: .destructive, action: clearTasks) {
                    Text("Cancel")
                }
            })
            .tint(.red)
            .disabled(tasks.count == 0)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsPage()
    }
}
