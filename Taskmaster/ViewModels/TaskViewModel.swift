import SwiftUI
import SwiftData

class TaskViewModel: ObservableObject {
    
    @Environment(\.modelContext) private var context
    @Query private var tasks: [TaskItem]
    
    init() {
        
    }
    
    func deleteTask(task: TaskItem) {
        context.delete(task)
    }
    
    func duplicateTask(task: TaskItem) {
        let model = TaskItem(body: task.body, isComplete: task.isComplete)
        context.insert(model)
    }
    
    func moveTask(from: IndexSet, to: Int) {
        // TODO Move task code
    }
}
