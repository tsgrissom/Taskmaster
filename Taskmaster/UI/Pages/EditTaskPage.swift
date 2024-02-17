import SwiftUI

struct EditTaskPage: View {
    
    // MARK: Environment Variables
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.colorScheme)
    private var systemColorScheme
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject
    private var settings: SettingsStore
    
    // MARK: Constants
    private let ALERT_COLOR_BG: Color = .red
    private let ALERT_COLOR_FG: Color = .white
    
    private let task: TaskItem
    private let originalText: String
    
    // MARK: Init
    init(task: TaskItem) {
        self.task = task
        self.originalText = task.body
        self.inputText = task.body
    }
    
    // MARK: Stateful Variables
    // Alert Box
    @State
    private var alertVisible = false
    @State
    private var alertText = ""
    
    // Buttons
    /*
     * None - 0
     * Fail - 1
     * Succ - 2
     */
    @State
    private var animateClearButton = 0
    @State
    private var animateRestoreButton = 0
    @State
    private var animateSaveButton = 0
    
    // Text Field
    @State
    private var inputText = String()
    @FocusState
    private var isInputFocused: Bool
    
    // MARK: Computed Variables
    
    /**
     Checks whether the new trimmed new text is identical to the original text of the ItemModel.
     */
    private var isTextIdenticalToOriginal: Bool {
        inputText.trim() == originalText
    }
    
    /**
     Checks whether the new trimmed text meets the length requirement of ItemModel titles.
     */
    private var isTextPreparedForSubmission: Bool {
        inputText.trim().count >= 4
    }
    
    /**
     Checks whether haptics are enabled within the user's settings.
     */
    private var shouldUseHaptics: Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    private var haptics: HapticGenerator {
        HapticGenerator(shouldUseHaptics)
    }
    
    private var systemTextColor: Color {
        systemColorScheme == .dark ? .white : Color.primary
    }
    
    /**
     Creates a modified frame width for the current device.
     If an iPad, 50% of the screen width.
     If an iPhone, 85% of the screen width.
     */
    private var modifiedFrameWidth: CGFloat {
        let screenWidth = DeviceUtilities.getScreenWidth()
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return screenWidth * 0.5
        case .phone:
            return screenWidth * 0.85
        default:
            return screenWidth
        }
    }
    
    // MARK: Body Start
    public var body: some View {
        let devicePadding = DeviceUtilities.isPhone() ? 14.0 : 20.0
        return ScrollView {
            VStack {
                rowTextInput
                sectionControlButtons
                
                Spacer()
                
                if alertVisible {
                    sectionAlertBox
                    Spacer()
                }
            }
            .padding(devicePadding)
            .padding(.top, 20)
        }
        .navigationTitle("Editing Task")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if $settings.shouldAutoFocusTextFields.wrappedValue {
                isInputFocused = true
            }
        }
    }
    
    // MARK: Event Functions
    
    private func updateAndReturn(after delay: CGFloat = 1.0) {
        task.body = inputText.trim()
        task.updatedAt = Date().timeIntervalSince1970
        try? context.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            dismiss.callAsFunction()
        }
    }
    
    // MARK: Functions
    
    private func getRestoreConfirmAlert() -> Alert {
        let primaryBtn: Alert.Button = .destructive(Text("Confirm")) {
            inputText = originalText
            haptics.notification()
        }
        return Alert(
            title: Text("Clear what you've written?"),
            message: Text("This action cannot be undone"),
            primaryButton: primaryBtn,
            secondaryButton: .cancel()
        )
    }
    
    private func flashAlert(
        text: String,
        duration: Double = 15
    ) {
        func showAlert(duration: Double = 15.0) {
            withAnimation(.linear(duration: 0.2)) {
                alertVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.linear) {
                    alertVisible = false
                }
            }
        }
        
        alertText = text
        
        guard !alertVisible else {
            alertVisible = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAlert(duration: duration)
            }
            
            return
        }
        
        showAlert(duration: duration)
    }
}

// MARK: Layout Declaration

extension EditTaskPage {
    
    private var rowTextInput: some View {
        let prompt = Text("Old: \(originalText)")
            .foregroundColor(systemTextColor)
        return TextField("Type your edited text", text: $inputText, prompt: prompt, axis: .vertical)
            .lineLimit(1...4)
            .focused($isInputFocused)
            .modifier(TextFieldViewModifier())
            .frame(maxWidth: modifiedFrameWidth)
            .onSubmit {
                if inputText.trim().isEmpty || !isTextPreparedForSubmission {
                    isInputFocused = false
                } else {
                    updateAndReturn(after: 0)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        // Leading Keyboard Toolbar Items
                        Button(action: {
                            inputText = ""
                        }) {
                            Image(systemName: "eraser")
                        }
                        .disabled(inputText.isEmpty)
                        Button(action: {
                            inputText = originalText
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        Button(action: {
                            updateAndReturn()
                        }) {
                            Image(systemName: "checkmark")
                        }
                
                        Button(action: {
                            inputText = originalText
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .disabled(inputText == originalText)
                        
                        // Trailing Keyboard Toolbar Items
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
    
    private var sectionControlButtons: some View {
        VStack {
            HStack(alignment: .center) {
                buttonSave
                    .disabled(!isTextPreparedForSubmission)
                Spacer()
                    .frame(maxWidth: 8)
                buttonClear
                    .disabled(inputText.isEmpty)
            }
            .frame(maxWidth: modifiedFrameWidth)
            .padding(.top, 2)
            
            HStack(alignment: .center) {
                buttonRestore
            }
            .frame(maxWidth: modifiedFrameWidth)
            .padding(.top, 2)
        }
    }
    
    private var sectionAlertBox: some View {
        HStack {
            Text(alertText)
                .padding(15)
                .foregroundColor(ALERT_COLOR_FG)
        }
        .frame(minWidth: modifiedFrameWidth)
        .background(ALERT_COLOR_BG)
        .cornerRadius(15)
        .foregroundStyle(ALERT_COLOR_FG)
        .padding(.top, 10)
        .transition(.move(edge: .leading))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                alertVisible = false
            }
        }
    }
    
    private func onButtonClearPress() {
        func feedbackEmpty() {
            haptics.notification(.warning)
            animateClearButton = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                animateClearButton = 0
            }
        }
        
        guard !inputText.trim().isEmpty else {
            feedbackEmpty()
            return
        }
        
        // Otherwise, text field is not empty, clear it, play fx
        
        inputText = ""
        
        animateClearButton = 2
        haptics.notification()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animateClearButton = 0
        }
    }
    
    private var buttonClear: some View {
        let bgColor = animateClearButton==2 ? Color.green : Color.danger
        let symbol  = animateClearButton==1 ? "xmark" : "eraser.fill"
        
        return Button(action: onButtonClearPress) {
            Image(systemName: symbol)
                .imageScale(.large)
                .frame(width: 125, height: 30)
        }
        .buttonStyle(.bordered)
        .tint(bgColor)
    }
    
    private func onButtonRestorePress() {
        if inputText.trim() == originalText {
            haptics.notification(.warning)
            animateRestoreButton = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                animateRestoreButton = 0
            }
            return
        }
        
        haptics.notification()
        animateRestoreButton = 2
        inputText = originalText
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animateRestoreButton = 0
        }
    }
    
    private var buttonRestore: some View {
        let symbol = switch (animateRestoreButton) {
        case 1:
            "xmark"
        case 2:
            "checkmark"
        default:
            "square.on.square"
        }
        
        return Button(action: onButtonRestorePress) {
            Label("Restore original text", systemImage: symbol)
        }
        .buttonStyle(.bordered)
        .tint(.yellow)
        .disabled(inputText.isNotEmpty && inputText.trim() == originalText)
        .symbolEffect(.bounce, value: animateRestoreButton)
    }
    
    private func onButtonSavePress() {
        func feedbackTooShort() {
            let tooShortText = "Tasks must be at least 4 characters in length 📏"
            let tooShortText2 = "Task is too short. Please enter at least 4 characters."
            
            animateSaveButton = 1
            haptics.notification(.warning)
            
            flashAlert(text: alertVisible ? tooShortText2 : tooShortText)
            // Provide second text for UX if the user tap-spams
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                animateSaveButton = 0
            }
        }
        
        func feedbackIdentical() {
            animateSaveButton = 2
            haptics.notification(.success)
            dismiss.callAsFunction()
        }
        
        guard isTextPreparedForSubmission else {
            feedbackTooShort()
            return
        }
        
        guard !isTextIdenticalToOriginal else {
            feedbackIdentical()
            return
        }
        
        animateSaveButton = 2
        haptics.notification()
        
        updateAndReturn()
    }
    
    private var buttonSave: some View {
        let symbol = animateSaveButton==1 ? "xmark" : "checkmark"
        let bgColor: Color = switch (animateSaveButton) {
        case 1:
            Color.danger
        case 2:
            Color.green
        default:
            Color.accentColor
        }
        
        return Button(action: onButtonSavePress) {
            Image(systemName: symbol)
                .imageScale(.large)
                .frame(width: 125, height: 30)
        }
        .buttonStyle(.bordered)
        .tint(bgColor)
    }
}

// MARK: Preview

#Preview {
    NavigationStack {
        EditTaskPage(task: MockupUtilities.getMockTask())
    }
    .environmentObject(SettingsStore())
}
