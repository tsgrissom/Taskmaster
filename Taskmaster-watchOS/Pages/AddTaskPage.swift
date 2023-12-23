import SwiftUI

struct AddTaskPage: View {
    
    @Environment(\.modelContext)
    private var context
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var inputText = ""
    
    var body: some View {
        VStack {
            Spacer()
            inputTextField
            HStack {
                buttonErase
                buttonSubmit
            }
        }
        .navigationTitle("New Task")
    }
    
    private var inputTextField: some View {
        let text = Text("Describe your task")
        return TextField(text: $inputText, prompt: text, axis: .vertical) {
            text
        }
    }
    
    private var buttonErase: some View {
        func onPress() {
            inputText = ""
        }
        
        return Button(action: onPress) {
            Image(systemName: "eraser")
        }
        .disabled(inputText.isEmpty)
        .tint(.red)
    }
    
    private var buttonSubmit: some View {
        func onPress() {
            let newTask = TaskItem(body: inputText.trim())
            context.insert(newTask)
            dismiss.callAsFunction()
        }
        
        return Button(action: onPress) {
            Image(systemName: "checkmark")
        }
        .disabled(inputText.trim().isEmpty)
    }
}

#Preview {
    NavigationStack {
        AddTaskPage()
    }
}
