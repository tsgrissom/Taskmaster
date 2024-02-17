import SwiftUI
import SwiftData

/// Presents the user-facing settings for Taskmaster. Various types of settings are organized across sections to be customized to the user's liking.
struct SettingsPage: View {
    
    // MARK: Environment Variables
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject
    private var settings: SettingsStore
    
    @Query
    private var tasks: [TaskItem]
    
    // MARK: Stateful Variables
    @State
    private var showConfirmClearTasksAlert: Bool = false
    
    // MARK: Computed Variables
    private var shouldUseHaptics: Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    private var haptics: HapticGenerator {
        HapticGenerator(shouldUseHaptics)
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        VStack {
            List {
                appearanceSection
                appBehaviorSection
                listBehaviorSection
                miscSection
            }
            .tint(.accentColor)
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

// MARK: Layout Components
extension SettingsPage {
    
    /**
     Presents a section allowing for customizing the app's appearance.
     */
    private var appearanceSection: some View {
        Section("App Appearance") {
            Picker("Background", selection: $settings.themeBg) {
                Text("System").tag(ThemeBackgroundOption.system)
                Text("Dark").tag(ThemeBackgroundOption.dark)
                Text("Light").tag(ThemeBackgroundOption.light)
            }
            Picker("Accent", selection: $settings.themeAccent) {
                Text("Default (Purple)").tag(ThemeAccentOption.purple)
                Text("iOS (Blue)").tag(ThemeAccentOption.blue)
            }
            Picker("Indicator Frame", selection: $settings.indicatorFrame) {
                Text("App Shaped").tag(CompletionIndicatorFrameOption.app)
                Text("Circular").tag(CompletionIndicatorFrameOption.circle)
                Text("Diamond").tag(CompletionIndicatorFrameOption.diamond)
                Text("Round Square").tag(CompletionIndicatorFrameOption.roundsquare)
                Text("Square").tag(CompletionIndicatorFrameOption.square)
            }
            Picker("Indicator Mark", selection: $settings.indicatorSymbol) {
                Text("Asterisk").tag(CompletionIndicatorSymbolOption.asterisk)
                Text("Checkmark").tag(CompletionIndicatorSymbolOption.checkmark)
                Text("Scribble").tag(CompletionIndicatorSymbolOption.scribble)
                Text("X-Mark").tag(CompletionIndicatorSymbolOption.xmark)
            }
            Toggle(isOn: $settings.shouldFillIndicator) {
                Text("Indicator Fill on Complete")
            }
            Picker("Quick Add Button Style", selection: $settings.quickAddButtonStyle) {
                Text("Large").tag(QuickAddButtonStyleOption.large)
                Text("Small").tag(QuickAddButtonStyleOption.small)
                Text("Material").tag(QuickAddButtonStyleOption.material)
            }
            Picker("Date Format Style", selection: $settings.dateFormat) {
                Text("American").tag(DateFormatOption.american)
                Text("International").tag(DateFormatOption.international)
            }
        }
    }
    
    /**
     Presents a section allowing for customizing the app's general behavior.
     */
    private var appBehaviorSection: some View {
        Section("App Behavior") {
            Toggle(isOn: $settings.shouldUseHaptics) {
                Text("Use haptic feedback (iPhone)")
            }
//            Toggle(isOn: $settings.shouldOpenSettingsOnLeftEdgeSlide) {
//                Text("Swipe from left edge to open settings")
//            }
//            Toggle(isOn: $settings.isDebugEnabled) {
//                Text("Debug enabled")
//            }
            Toggle(isOn: $settings.shouldAutoFocusTextFields) {
                Text("Auto-focus text fields")
            }
        }
    }
    
    /**
     Presents a section allowing for customizing the main list's behavior.
     */
    private var listBehaviorSection: some View {
        Section("Customize list behavior") {
            Toggle(isOn: $settings.shouldAlphabetizeList) {
                Text("Alphabetize task items")
            }
            Toggle(isOn: $settings.shouldAutoDeleteTaskOnCheckoff) {
                Text("Auto-delete task on check-off")
            }
        }
    }
    
    /**
     Presents miscellaneous options which did not fit under other categories.
     */
    private var miscSection: some View {
        let count = tasks.count
        let countStr = StringUtilities.createCountString("task", arr: tasks, capitalize: false, pluralize: true)
        
        func onClearButtonPress() {
            haptics.notification(.warning)
            showConfirmClearTasksAlert.toggle()
        }
        
        func clearConfirmAlert() -> Alert {
            let message = Text("\(countStr) will be cleared (cannot be undone)")
            let primaryButton: Alert.Button = .destructive(Text("Confirm")) {
                for task in tasks {
                    context.delete(task)
                }
            }
            return Alert(
                title: Text("Clear your tasks?"),
                message: message,
                primaryButton: primaryButton,
                secondaryButton: .cancel()
            )
        }
        
        func noTasksAlert() -> Alert {
            Alert(title: Text("There are no tasks to dismiss!"))
        }
        
        return Section("Miscellaneous") {
            HStack {
                Button(action: onClearButtonPress) {
                    Text("Clear \(countStr)")
                }
                .buttonStyle(.bordered)
                .background(Color.danger)
                .cornerRadius(5)
                .foregroundColor(.white)
                .padding(2)
                .alert(isPresented: $showConfirmClearTasksAlert, content: count > 0 ? clearConfirmAlert : noTasksAlert)
            }
        }
    }
}

// MARK: Preview
#Preview {
    NavigationStack {
        SettingsPage()
            .environmentObject(SettingsStore())
    }
}
