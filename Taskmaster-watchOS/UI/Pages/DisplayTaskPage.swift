import SwiftUI
import SwiftData

struct DisplayTaskPage: View {
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context
    
    @State
    private var animateDeleteButton = false
    
    private let task: TaskItem
    
    init(_ task: TaskItem) {
        self.task = task
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("\"\(task.body)\"")
                    Spacer()
                }
                rowCompletionState
                    .padding(.vertical)
                    .onTapGesture {
                        task.isComplete.toggle()
                        task.updatedAt = Date().timeIntervalSince1970
                        try? context.save()
                    }
                HStack {
                    buttonDuplicate
                    buttonDelete
                }
            }
            .padding(.top, 10)
        }
        .navigationTitle("Task")
    }
    
    private var buttonDelete: some View {
        func onPress() {
            withAnimation(.smooth(duration: 0.4)) {
                animateDeleteButton = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                context.delete(task)
                try? context.save()
                dismiss.callAsFunction()
            }
        }
        
        let degrees = animateDeleteButton ? 180.0 : 0.0
        
        return Button(action: onPress) {
            Image(systemName: "trash")
                .rotationEffect(.degrees(degrees))
        }
        .tint(.red)
    }
    
    private var buttonDuplicate: some View {
        func onPress() {
            let duplicate = TaskItem(body: task.body, isComplete: task.isComplete)
            context.insert(duplicate)
            try? context.save()
            dismiss.callAsFunction()
        }
        
        return Button(action: onPress) {
            Image(systemName: "square.on.square")
        }
    }
    
    private var rowCompletionState: some View {
        HStack {
            ZStack {
                if task.isComplete {
                    Image(systemName: "xmark")
                        .foregroundStyle(.purple)
                }
                
                Image(systemName: "square")
                    .foregroundStyle(.primary)
            }
            Text(task.isComplete ? "Completed" : "Incomplete")
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        DisplayTaskPage(MockupUtilities.getMockTask(isComplete: false))
    }
}
