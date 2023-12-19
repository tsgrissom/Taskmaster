import SwiftUI

struct EditView: View {
    
    private let task: TaskItem
    private let originalText: String
    
    // MARK: Init
    init(task: TaskItem) {
        self.task = task
        self.originalText = task.body
        self.inputText = originalText
    }
    
    // MARK: Constants
    private let ALERT_BG_COLOR = Color.red
    private let ALERT_FG_COLOR = Color.white
    private let MIN_LENGTH = 16
    
    // MARK: Environment Variables
    @Environment(\.presentationMode)
    private var presentationMode
    @Environment(\.colorScheme)
    private var systemColorScheme
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject
    private var settings: SettingsStore
    
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
    private var btnClearAnimated = 0
    @State
    private var btnRestoreAnimated = 0
    @State
    private var btnSaveAnimated = 0
    
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
        inputText.trim().count >= MIN_LENGTH
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
        systemColorScheme == .dark ? .white : .black
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
                rowControlButtons
                    .padding(.top, 2)
                    .frame(width: modifiedFrameWidth)
                
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
        try? context.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func onSaveButtonPress() {
        func feedbackTooShort() {
            let tooShortText = "Tasks must be at least \(MIN_LENGTH) characters in length 📏"
            let tooShortText2 = "Task is too short. Please enter at least \(MIN_LENGTH) characters."
            
            btnSaveAnimated = 1
            haptics.notification(.warning)
            
            flashAlert(text: alertVisible ? tooShortText2 : tooShortText)
            // Provide second text for UX if the user tap-spams
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                btnSaveAnimated = 0
            }
        }
        
        func feedbackIdentical() {
            btnSaveAnimated = 2
            haptics.notification(.success)
            
            presentationMode.wrappedValue.dismiss()
        }
        
        guard isTextPreparedForSubmission else {
            feedbackTooShort()
            return
        }
        
        guard !isTextIdenticalToOriginal else {
            feedbackIdentical()
            return
        }
        
        btnSaveAnimated = 2
        haptics.notification()
        
        updateAndReturn()
    }
    
    private func onClearButtonPress() {
        func feedbackEmpty() {
            haptics.notification(.warning)
            btnClearAnimated = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                btnClearAnimated = 0
            }
        }
        
        guard !inputText.trim().isEmpty else {
            feedbackEmpty()
            return
        }
        
        // Otherwise, text field is not empty, clear it, play fx
        
        inputText = ""
        
        btnClearAnimated = 2
        haptics.notification()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            btnClearAnimated = 0
        }
    }
    
    private func onRestoreButtonPress() {
        guard inputText.trim().isEmpty else {
            btnRestoreAnimated = 1
            haptics.notification(.warning)
            return
        }
        
        inputText = originalText
        btnRestoreAnimated = 2
        haptics.notification()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            btnRestoreAnimated = 0
        }
    }
    
    private func onSubmitTextField() {
        if inputText.trim().isEmpty || !isTextPreparedForSubmission {
            isInputFocused = false
        } else {
            updateAndReturn(after: 0)
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

extension EditView {
    
    private var rowTextInput: some View {
        let prompt = Text("Old: \(originalText)")
            .foregroundColor(systemTextColor)
        return TextField("Type your edited text", text: $inputText, prompt: prompt, axis: .vertical)
            .lineLimit(1...4)
            .focused($isInputFocused)
            .modifier(TextFieldViewModifier())
            .frame(maxWidth: modifiedFrameWidth)
            .onSubmit(onSubmitTextField)
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
                            inputText = originalText
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
    
    private var buttonClear: some View {
        let bgColor = btnClearAnimated==2 ? Color.green : Color.danger
        let symbol  = btnClearAnimated==1 ? "xmark" : "eraser.fill"
        
        return Button(action: onClearButtonPress) {
            Image(systemName: symbol)
                .modifier(ControlRowButtonViewModifier())
                .background(bgColor)
                .cornerRadius(10)
        }
    }
    
    private var buttonRestore: some View {
        let symbol = switch (btnRestoreAnimated) {
        case 1:
            "xmark"
        case 2:
            "arrow.up"
        default:
            "square.on.square"
        }
        
        return Button(action: onRestoreButtonPress) {
            Text("Restore original text")
            Image(systemName: symbol)
        }
        .buttonStyle(.bordered)
        .frame(height: 20)
        .frame(maxWidth: .infinity)
        .tint(.yellow)
    }
    
    private var buttonSave: some View {
        let symbol = switch (btnSaveAnimated) {
        case 1:
            "xmark"
        case 2:
            "square.and.arrow.down"
        default:
            "checkmark"
        }
        let bgColor: Color = switch (btnSaveAnimated) {
        case 1:
            Color.danger
        case 2:
            Color.green
        default:
            isTextPreparedForSubmission ? Color.accentColor : Color.gray.opacity(0.45)
        }
        
        return Button(action: onSaveButtonPress) {
            Image(systemName: symbol)
                .modifier(ControlRowButtonViewModifier())
                .background(bgColor)
                .cornerRadius(10)
        }
    }
    
    private var rowControlButtons: some View {
        VStack {
            HStack(alignment: .center) {
                buttonSave
                Spacer()
                    .frame(maxWidth: 8)
                buttonClear
            }
            
            HStack(alignment: .center) {
                buttonRestore
            }
            .frame(width: modifiedFrameWidth)
            .padding(.top, 8)
        }
    }
    
    private var sectionAlertBox: some View {
        HStack {
            Text(alertText)
                .padding(15)
                .foregroundColor(ALERT_FG_COLOR)
        }
        .frame(minWidth: modifiedFrameWidth)
        .background(ALERT_BG_COLOR)
        .cornerRadius(15)
        .foregroundStyle(ALERT_FG_COLOR)
        .padding(.top, 10)
        .transition(.move(edge: .leading))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                alertVisible = false
            }
        }
    }
}

// MARK: Preview

#Preview {
    NavigationStack {
        EditView(task: MockupUtilities.getMockTask())
    }
    .environmentObject(SettingsStore())
}
