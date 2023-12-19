import SwiftUI
import SwiftData

private struct ListRow: View {
    
    private let taskBody: String
    @State
    private var completed: Bool
    
    init(
        taskBody: String = "Lorem ipsum dolor shipsum dipsum foobar",
        completed: Bool = false
    ) {
        self.taskBody = taskBody
        self.completed = completed
    }
    
    private var checkbox: some View {
        ZStack {
            Image(systemName: "square")
            if completed {
                Image(systemName: "xmark")
            }
        }
        .foregroundStyle(completed ? Color.green : Color.primary)
        .onTapGesture {
            completed.toggle()
        }
    }
    
    public var body: some View {
        HStack {
            checkbox
            Text("\(taskBody)")
                .font(.footnote)
        }
    }
}

struct DisplayTaskListPage: View {
    
    public var body: some View {
        List {
            ForEach(1...50, id: \.self) { _ in
                ListRow()
            }
        }
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: Text("This is the add task page")) {
                    Image(systemName: "plus")
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: Text("This is the settings page")) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("Main View") {
    NavigationStack {
        DisplayTaskListPage()
    }
}

#Preview("TaskListRowView") {
    VStack {
        ListRow()
        ListRow(completed: true)
    }
}
