import SwiftUI

/// A view for creating new tasks and adding them to the view model
struct AddTaskPage: View {
    
    // MARK: Constants
    private let ALERT_BG_COLOR = Color.red
    private let ALERT_FG_COLOR = Color.white
    private let MIN_LENGTH     = 16
    
    // MARK: Environment Variables
    @Environment(\.colorScheme)
    private var systemColorScheme
    @Environment(\.modelContext)
    private var context
    @Environment(\.presentationMode)
    private var presentationMode
    
    @EnvironmentObject
    private var settings: SettingsStore
    
    // MARK: Stateful Variables
    // Alert Box
    @State
    private var alertVisible = false
    @State
    private var alertText    = ""
    
    // Button States
    /*
     * None - 0
     * Fail - 1
     * Succ - 2
     */
    @State
    private var btnClearAnimated = 0
    @State
    private var btnSaveAnimated  = 0
    
    // Text Fields
    @FocusState
    private var isInputFocused: Bool
    @State
    private var inputText = String()
    
    // MARK: Computed Variables
    
    /**
     Checks if the text field content variable is prepared to be submitted.
     Specifically, it requires that the trimmed value of the text field's character count exceeds the minimum required task length.
     */
    private var isTextPreparedForSubmission: Bool {
        inputText.trim().count >= MIN_LENGTH
    }
    
    private var shouldShowTaskPreviewBox: Bool {
        inputText.trim().count >= 1
    }
    
    /**
     Whether the text field should be focused automatically per the user settings.
     */
    private var shouldAutoFocus: Bool {
        $settings.shouldAutoFocusTextFields.wrappedValue
    }
    
    /**
     Whether haptics should be deployed per the user settings.
     */
    private var shouldUseHaptics: Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    /**
     Generates haptic feedback via a simple syntax
     */
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
                rowForm
                rowControlButtons
                Spacer()
                
                if alertVisible {
                    sectionAlertBox
                }
                
                if shouldShowTaskPreviewBox  {
                    sectionTaskPreviewBox
                }
                
                Spacer()
            }
            .padding(devicePadding)
            .padding(.top, 20)
        }
        .navigationTitle("Composing a Task")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if shouldAutoFocus {
                isInputFocused = true
            }
        }
    }
    
    // MARK: Event Functions
    
    /**
     Checks if the text is ready for submission. If so, it is added to the view model
     and the presentation is dismissed after a delay. Otherwise, the unprepared feedback
     is played out.
     */
    private func addAndReturn(after delay: CGFloat = 0.4) {
        guard isTextPreparedForSubmission else {
            feedbackUnprepared()
            return
        }
        
        let newTask = TaskItem(body: inputText.trim())
        context.insert(newTask)
        
        // Short delay to visually display animation before transitioning back to list
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    /**
     Flashes an alert informing the user that their input is too short. This coincides with a few
     UX button modifications which are undone shortly after.
     */
    private func feedbackUnprepared() {
        let tooShort = "Tasks must be at least \(MIN_LENGTH) characters in length 📏"
        let tooShort2 = "Task is too short. Please enter at least \(MIN_LENGTH) characters."
        btnSaveAnimated = 1
        
        flashAlert(text: alertVisible ? tooShort2 : tooShort)
        haptics.notification(.warning)
        
        if !isInputFocused {
            isInputFocused = true
        }
        
        // 3s later, restore the button's color & symbol
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            btnSaveAnimated = 0
        }
    }
    
    /**
     Triggered when the save button is pressed. Verifies that the text value is prepared, and if so
     plays out a few button effects, adds the new task to the view model, and then dismisses the
     presentation.
     */
    private func onSaveButtonPress() {
        // If save is clicked, but less than 3 characters are in the text field
        guard isTextPreparedForSubmission else {
            feedbackUnprepared()
            return
        }
        
        // Otherwise, text is ready and the save can proceed
        
        if isInputFocused {
            isInputFocused = false
        }
        
        btnSaveAnimated = 2
        haptics.notification()
        
        addAndReturn()
    }
    
    /**
     Triggered when the clear button is pressed. Checks to ensure the text value is not empty.
     If there is nothing to clear, it plays out one set of effects. If it has value, an alert is
     displayed alongside several effects such as haptics and button animations. The text field is
     cleared and shortly after the button effects are reset.
     */
    private func onClearButtonPress() {
        func feedbackShake() {
            haptics.notification(.warning)
            btnClearAnimated = 1
        }
        
        func feedbackSuccess() {
            btnClearAnimated = 2
        }
        
        func resetButtonEffects() {
            btnClearAnimated = 0
            btnSaveAnimated  = 0
        }
        
        // Capture future btn result, which is an inversion of if the str is empty
        let success = !inputText.isEmpty
        
        guard success else {
            feedbackShake()
            return
        }
        
        inputText = ""
        haptics.notification()
        flashAlert(
            text: "Text field cleared",
            duration: 2.0
        )
        feedbackSuccess()
        
        // Reset btn attributes w/ animation after 1s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            resetButtonEffects()
        }
    }
    
    // MARK: Functions
    
    private func flashAlert(
        text: String,
        duration: Double = 15.0
    ) {
        alertText = text
        
        // In case the alert is already visible, hide it, and slide it back in after 1/2 a second
        guard !alertVisible else {
            alertVisible = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAlert(duration: duration)
            }
            
            return
        }
        
        showAlert(duration: duration)
    }
    
    private func showAlert(duration: Double = 15.0) {
        withAnimation(.linear(duration: 0.2)) {
            alertVisible = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.linear) {
                alertVisible = false
            }
        }
    }
}

// MARK: Layout Declarations

extension AddTaskPage {
    
    /**
     Presents a row containing the primary text field of the view.
     */
    private var rowForm: some View {
        let prompt: Text = Text("Type your new task...")
            .foregroundColor(systemTextColor)
        return HStack {
            TextField("Type your new task", text: $inputText, prompt: prompt, axis: .vertical)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .modifier(TextFieldViewModifier())
                .frame(maxWidth: modifiedFrameWidth)
                .onSubmit {
                    addAndReturn(after: 0) // Save and return to task list immediately
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack {
                            Button(action: {
                                inputText = ""
                            }) {
                                Image(systemName: "eraser")
                            }
                            .disabled(inputText.isEmpty)
                            
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
    }
    
    private var buttonClear: some View {
        let symbol = btnClearAnimated == 1 ? "xmark" : "eraser.fill"
        let danger:   Color = .danger
        let disabled: Color = .gray.opacity(0.45)
        let bgColor = switch (btnClearAnimated) {
        case 1:
            danger
        case 2:
            Color.green
        default:
            !inputText.isEmpty ? danger : disabled
        }
        
        return Button(action: onClearButtonPress) {
            Image(systemName: symbol)
                .modifier(ControlRowButtonViewModifier())
                .background(bgColor)
                .cornerRadius(10)
        }
    }
    
    private var buttonSave: some View {
        let prepared: Color = .accentColor
        let disabled: Color = .gray.opacity(0.45)
        let bgColor:  Color = switch(btnSaveAnimated) {
        case 1:
            .danger
        case 2:
            .green
        default:
            isTextPreparedForSubmission ? prepared : disabled
        }
        let symbol = switch (btnSaveAnimated) {
        case 1:
            "xmark"
        case 2:
            "square.and.arrow.down"
        default:
            "checkmark"
        }
        
        return Button(action: onSaveButtonPress) {
            Image(systemName: symbol)
                .modifier(ControlRowButtonViewModifier())
                .background(bgColor)
                .cornerRadius(10)
        }
    }
    
    private var rowControlButtons: some View {
        HStack(alignment: .center) {
            buttonSave
            Spacer()
                .frame(maxWidth: 8)
            buttonClear
        }
        .padding(.top, 2)
        .frame(maxWidth: modifiedFrameWidth)
    }
    
    /**
     Displays issues with the user input. Hidden by default.
     */
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
        .transition(.move(edge: .bottom))
        .onTapGesture {
            withAnimation {
                alertVisible = false
            }
        }
    }
    
    private var sectionTaskPreviewBox: some View {
        TaskPreviewBox(
            isTextPrepared: isTextPreparedForSubmission,
            text: inputText
        )
        .frame(width: modifiedFrameWidth)
        .padding(.top, 8)
        .padding(.horizontal)
        .transition(.move(edge: .leading))
    }
}

// MARK: Preview

#Preview {
    NavigationStack {
        AddTaskPage()
    }
    .environmentObject(SettingsStore())
}
