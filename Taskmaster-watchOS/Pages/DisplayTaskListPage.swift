import SwiftUI
import SwiftData

struct DisplayTaskListPage: View {
    
    @Environment(\.modelContext)
    private var context
    
    @Query
    private var tasks: [TaskItem]
    
    public var body: some View {
        let count = StringUtilities.createCountString("task", arr: tasks, overrideEmpty: "Tasks")
        return VStack {
            if tasks.isEmpty {
                sectionOnboarding
            } else {
                sectionTaskList
            }
        }
        .navigationTitle(count)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { buttonSettings }
            ToolbarItem(placement: .topBarTrailing) { buttonAdd }
        }
    }
    
    private var buttonAdd: some View {
        NavigationLink(destination: AddTaskPage()) {
            Image(systemName: "plus")
                .foregroundStyle(.purple)
        }
        .buttonStyle(.plain)
    }
    
    private var buttonSettings: some View {
        NavigationLink(destination: SettingsPage()) {
            Image(systemName: "gear")
        }
        .buttonStyle(.plain)
    }
    
    private var sectionTaskList: some View {
        VStack {
            List {
                ForEach(tasks) { task in
                    ListRow(for: task)
                }
            }
        }
    }
    
    private var sectionOnboarding: some View {
        VStack {
            Spacer()
            Text("You have not added any tasks")
            Spacer()
            NavigationLink(destination: AddTaskPage()) {
                Text("Add Task")
            }
            .tint(.purple)
        }
    }
}

#Preview {
    NavigationStack {
        DisplayTaskListPage()
    }
}
