import SwiftUI
import SwiftData

struct ListRow: View {
    
    @Environment(\.modelContext)
    private var context
    
    private let task: TaskItem
    
    init(for task: TaskItem) {
        self.task = task
    }
    
    init(
        taskBody: String = "Lorem ipsum dolor shipsum dipsum foobar",
        completed: Bool = false
    ) {
        self.task = TaskItem(body: taskBody, isComplete: completed)
    }
    
    @State
    private var showActionSheet = false
    
    private func delete() {
        context.delete(task)
        try? context.save()
    }
    
    private func toggleCompletion() {
        task.isComplete.toggle()
        try? context.save()
    }
    
    public var body: some View {
        HStack {
            checkbox
            Text("\(task.body)")
                .font(.footnote)
        }
        .confirmationDialog("Task: \(task.body)", isPresented: $showActionSheet, titleVisibility: .hidden, actions: {
            Button(action: delete) {
                Text("Delete")
            }
            Button(task.isComplete ? "Mark Incomplete" : "Mark Completed") {
                toggleCompletion()
            }
            Button("Cancel", role: .destructive) {
                showActionSheet = false
            }
            .tint(.blue)
        })
        .onLongPressGesture {
            showActionSheet.toggle()
        }
    }
    
    private var checkbox: some View {
        ZStack {
            if task.isComplete {
                Image(systemName: "xmark")
                    .foregroundStyle(task.isComplete ? Color.purple : Color.primary)
            }
            Image(systemName: "square")
                .foregroundStyle(.primary)
        }
        .onTapGesture {
            toggleCompletion()
        }
    }
}

#Preview {
    VStack {
        ListRow()
        ListRow(completed: true)
    }
}
