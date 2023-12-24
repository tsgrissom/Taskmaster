import SwiftUI
import SwiftData

struct DisplayTaskItemPage: View {
    
    // MARK: Environment Variables
    @Environment(\.colorScheme)
    private var systemColorScheme
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject
    private var settings: SettingsStore
    
    // MARK: Constants
    private let MIN_LENGTH = 16
    private let completedColor: Color
    private let task: TaskItem
    
    // MARK: Stateful Variables
    // Buttons
    @State
    private var buttonEditAnimate = false
    @State
    private var buttonDuplicateAnimate = false
    @State
    private var buttonDeleteAnimate = false
    @State
    private var buttonResetAnimate = false
    @State
    private var buttonSaveAnimate = 0
    
    // Row Visibility
    @State
    private var rowTaskBodyIsVisible = true
    @State
    private var rowEditTaskBodyIsVisible = false
    
    // Text Field
    @State
    private var inputText = String()
    @FocusState
    private var isInputFocused: Bool
    
    // MARK: Computed Variables
    
    /**
     Computed variable which represents the appropriate text foreground color for the system's current light mode.
     */
    private var systemTextColor: Color {
        systemColorScheme == .dark ? .white : .black
    }
    
    /**
     Computed variable which represents the appropriate text foreground color for a task indicator, either the supplied
     `completedColor` or the appropriate system light mode foreground color.
     */
    private var foregroundColor: Color {
        task.isComplete ? completedColor : systemTextColor
    }
    
    /**
     The screen width of the device in use.
     */
    private var screenWidth: CGFloat {
        DeviceUtilities.getScreenWidth()
    }
    
    /**
     Whether haptics should be deployed per the user settings.
     */
    private var shouldUseHaptics: Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    /**
     Generates haptic feedback via a simple syntax.
     */
    private var haptics: HapticGenerator {
        HapticGenerator(shouldUseHaptics)
    }
    
    private var isTaskBodyEdited: Bool {
        return inputText != task.body && isInputFocused
    }
    
    // MARK: Initialization
    init(
        task: TaskItem,
        completedColor: Color = .accentColor
    ) {
        self.task = task
        self.completedColor = completedColor
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        let devicePad = DeviceUtilities.isTablet() ? 40.0 : 30.0
        let controlRowHzPad = 58.0
        ScrollView {
            VStack(spacing: 0) {
                sectionMetadata
                    .padding(.horizontal, controlRowHzPad)
                    .padding(.bottom, 15)
                
                ZStack {
                    layerContainerBackground
                    layerContainerForeground
                        .padding(.vertical, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                HStack {
                    buttonReset
                    buttonSave
                }
                .padding(.horizontal, controlRowHzPad)
                .padding(.bottom, 10)
                
                HStack {
                    buttonDismissView
                }
                .padding(.horizontal, controlRowHzPad)
            }
            .padding(.top, devicePad)
        }
    }
    
    // MARK: Superlayouts
    
    /**
     Presents a background layer for the view contents.
     */
    private var layerContainerBackground: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(.ultraThickMaterial)
    }
    
    /**
     Superview which lays out the foreground of the `DisplayItemView`.
     */
    private var layerContainerForeground: some View {
        VStack(spacing: 0) {
            if rowTaskBodyIsVisible {
                rowDisplayTaskBody
                    .frame(width: .infinity)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        startEditing()
                    }
            }
            
            if rowEditTaskBodyIsVisible {
                rowEditTaskBody
            }
            
            rowCompletionIndicator
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, 36)
                .onTapGesture {
                    task.isComplete.toggle()
                    task.updatedAt = Date().timeIntervalSince1970
                    try? context.save()
                    haptics.impact(.medium)
                }
            
            HStack(spacing: 10) {
                buttonEdit
                buttonDuplicate
            
                Spacer()
                
                buttonDelete
            }
            .padding(.top, 10)
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: Event Functions
    
    /**
     Hides the title row, shows the editing row, and focuses the text field.
     */
    private func startEditing() {
        haptics.impact(.soft)
        inputText = task.body
        rowTaskBodyIsVisible = false
        rowEditTaskBodyIsVisible = true
        isInputFocused = true
    }
    
    /**
     Unfocus the text field, hide the editing row, show the title row.
     */
    private func stopEditing() {
        isInputFocused = false
        rowEditTaskBodyIsVisible = false
        rowTaskBodyIsVisible = true
    }
    
    /**
     Unfocuses the text field, hides the editing row, shows the title row, and updates
     the ItemModel in the view model.
     */
    private func saveEditing() {
        task.body = inputText
        task.updatedAt = Date().timeIntervalSince1970
        try? context.save()
        
        stopEditing()
    }
    
    private func resetEdited() {
        stopEditing()
        inputText = task.body
    }
}

// MARK: Layout Components

extension DisplayTaskItemPage {
    
    /**
     Presents the title of the task.
     */
    private var rowDisplayTaskBody: some View {
        HStack {
            Text(task.body)
                .font(.title2)
                .fontWeight(.regular)
            Spacer()
        }
    }
    
    private var sectionMetadata: some View {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
//      formatter.dateFormat = "MMMM dd'th', yyyy 'at' h:mm a" // Old
//      formatter.dateFormat = "MM'/'dd'/'yyyy 'at' h:mm a"    // American
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"            // International
        timeFormatter.dateFormat = "'at' h:mm a"
        
        let createdUnix = task.createdAt
        let updatedUnix = task.updatedAt
        let createdDate = Date(timeIntervalSince1970: createdUnix)
        let updatedDate = Date(timeIntervalSince1970: updatedUnix)
        let createdDateFmt = dateFormatter.string(from: createdDate)
        let updatedDateFmt = dateFormatter.string(from: updatedDate)
        let createdTimeFmt = timeFormatter.string(from: createdDate)
        let updatedTimeFmt = timeFormatter.string(from: updatedDate)
        
        let shouldDisplayUpdated = createdUnix != updatedUnix
        
        return HStack(spacing: 2) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Created:")
                if shouldDisplayUpdated {
                    Text("Updated:")
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(createdDateFmt)")
                if shouldDisplayUpdated {
                    Text("\(updatedDateFmt)")
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(createdTimeFmt)")
                if shouldDisplayUpdated {
                    Text("\(updatedTimeFmt)")
                }
            }
            Spacer()
        }
        .font(.caption)
    }
    
    /**
     Presents a single text field which is hidden by default. This text row can be
     accessed in order to edit the associated ItemModel and save it to the view model.
     */
    private var rowEditTaskBody: some View {
        let prompt = Text("Type your new task title").foregroundColor(.gray)
        return ZStack {
            VStack {
                TextField("Edit task", text: $inputText, prompt: prompt, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .focused($isInputFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            HStack {
                                Button(action: {
                                    inputText = ""
                                }) {
                                    Image(systemName: "eraser")
                                }
                                .disabled(inputText.isEmpty)
                                
                                Button(action: {
                                    inputText = task.body
                                }) {
                                    Image(systemName: "arrow.counterclockwise")
                                }
                                
                                Spacer()
                                Button(action: {
                                    isInputFocused.toggle()
                                }) {
                                    Image(systemName: "keyboard.chevron.compact.down")
                                }
                            }
                            .tint(Color.gray)
                        }
                    }
            }
            .font(.system(size: 22))
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(Color.textField.gradient)
            .cornerRadius(10)
            .padding(.horizontal, 30)
            .padding(.bottom, 15)
            .onSubmit {
                saveEditing()
            }
            
            HStack {
                Spacer()
                Button(action: saveEditing) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .imageScale(.small)
                        .foregroundStyle(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom)
            .padding(.trailing, 2)
        }
    }
    
    /**
     Presents an indication of the associated task item model's completion status.
     This takes the form of a checkbox with the word "Completed" or "Incomplete".
     */
    private var rowCompletionIndicator: some View {
        let text: String = task.isComplete ? "Completed" : "Incomplete"
        
        var symbolView: some View {
            TaskCompletionIndicator(
                isComplete: task.isComplete,
                symbolColor: foregroundColor,
                fillCompleted: $settings.shouldFillIndicator.wrappedValue,
                frame: $settings.indicatorFrame.wrappedValue,
                indicator: $settings.indicatorSymbol.wrappedValue
            )
        }
        
        var textView: some View {
            VStack {
                Spacer()
                    .frame(maxHeight: 4)
                Text(text)
            }
        }
        
        return HStack(spacing: 3) {
            symbolView
                .fontWeight(.light)
            textView
                .font(.system(size: 20))
                .fontWeight(.regular)
                .offset(y: 0.5)
            Spacer()
        }
    }
    
    /**
     Presents an overlayed HStack giving the user a button to dismiss their keyboard while focused on the text field.
     */
    private var buttonDismissView: some View {
        func onPress() {
            haptics.impact(.light)
            dismiss()
        }
        
        return Button(action: onPress) {
            Spacer()
            Image(systemName: "xmark")
                .imageScale(.large)
                .foregroundStyle(systemColorScheme == .dark ? .white : .secondary)
            Spacer()
        }
        .buttonStyle(.bordered)
        .tint(.gray)
    }
    
    private var buttonReset: some View {
        func onPress() {
            withAnimation(.smooth(duration: 0.45)) {
                buttonResetAnimate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                buttonResetAnimate = false
                resetEdited()
            }
        }
        
        return Button(action: onPress) {
            Spacer()
            Image(systemName: "arrow.counterclockwise")
                .rotationEffect(.degrees(buttonResetAnimate ? -360 : 0.0))
            Spacer()
        }
        .buttonStyle(.bordered)
        .tint(.yellow)
        .disabled(!isTaskBodyEdited)
    }
    
    private var buttonSave: some View {
        func onPress() {
            if inputText.trim().count < MIN_LENGTH {
                buttonSaveAnimate = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    buttonSaveAnimate = 0
                }
                return
            }
            
            buttonSaveAnimate = 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                buttonSaveAnimate = 0
                saveEditing()
                dismiss()
            }
        }
        
        let color  = buttonSaveAnimate == 1 ? Color.red : Color.green
        let symbol = switch (buttonSaveAnimate) {
        case 1:
            "xmark"
        case 2:
            "square.and.arrow.down"
        default:
            "checkmark"
        }
        
        return Button(action: onPress) {
            Spacer()
            Image(systemName: symbol)
            Spacer()
        }
        .buttonStyle(.bordered)
        .tint(color)
        .disabled(!isTaskBodyEdited)
    }
    
    private var buttonDelete: some View {
        func onPress() {
            haptics.impact(.heavy)
            withAnimation {
                buttonDeleteAnimate = true
            }
            context.delete(task)
            try? context.save()
            
            stopEditing()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                withAnimation {
                    buttonDeleteAnimate = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                haptics.impact(.soft)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                dismiss()
            }
        }
        
        return Button(action: onPress) {
            Image(systemName: "trash")
                .imageScale(.medium)
                .rotationEffect(.degrees(buttonDeleteAnimate ? 180 : 0))
        }
        .buttonStyle(.borderless)
        .tint(.red)
    }
    
    private var buttonDuplicate: some View {
        func onPress() {
            let model = TaskItem(body: task.body, isComplete: task.isComplete)
            haptics.notification(.success)
            buttonDuplicateAnimate = true
            context.insert(model)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                dismiss()
            }
        }
        
        return Button("Duplicate") {
            onPress()
        }
        .buttonStyle(.borderless)
        .tint(buttonDuplicateAnimate ? Color(UIColor.systemBlue) : .blue)
    }
    
    private var buttonEdit: some View {
        func onPress() {
            haptics.impact(.light)
            buttonEditAnimate = true
            startEditing()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                buttonEditAnimate = false
            }
        }
        
        return Button("Edit") {
            onPress()
        }
        .buttonStyle(.borderless)
        .tint(buttonEditAnimate ? Color(UIColor.systemBlue) : .blue)
    }
}

//// MARK: Preview
//#Preview {
//    DisplayTaskItemPage(task: MockupUtilities.getMockTask(), completedColor: .accentColor)
//}
