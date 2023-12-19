import Foundation
import Combine

final class SettingsStore: ObservableObject {
    
    // MARK: Option Keys
    
    /**
     Stores the UserDefaults keys for settings to be written to and read from.
     */
    private enum Keys {
        // Appearance
        static let themeBg = "ThemeBackground"
        static let themeAccent = "ThemeAccent"
        static let indicatorFrame = "IndicatorFrame"
        static let indicatorChecked = "IndicatorChecked"
        static let indicatorFill = "IndicatorFill"
        static let quickAddButtonStyle = "QuickAddButtonStyle"
        // App Behavior
        static let debugEnabled = "DebugEnabled"
        static let useHaptics = "UseHaptics"
        static let openSettingsOnLeftEdgeSlide = "OpenSettingsOnLeftEdgeSlide"
        static let autoFocusTextFields = "AutoFocusTextFields"
        // List Behavior
        static let alphabetizeList = "AlphabetizeList"
        static let autoDeleteTaskOnCheckoff = "AutoDeleteTaskOnCheckoff"
    }
    
    private let cancellable: Cancellable
    private let defaults: UserDefaults
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    // MARK: UserDefaults Registration
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        defaults.register(defaults: [
            // Appearance
            Keys.themeBg: ThemeBackground.system.rawValue,
            Keys.themeAccent: ThemeAccent.purple.rawValue,
            Keys.indicatorFrame: CompletionIndicatorFrame.roundsquare.rawValue,
            Keys.indicatorChecked: CompletionIndicatorSymbol.checkmark.rawValue,
            Keys.indicatorFill: false,
            Keys.quickAddButtonStyle: QuickAddButtonStyle.small.rawValue,
            // App Behavior
            Keys.debugEnabled: false,
            Keys.useHaptics: true,
            Keys.openSettingsOnLeftEdgeSlide: true,
            Keys.autoFocusTextFields: true,
            // List Behavior
            Keys.autoDeleteTaskOnCheckoff: false,
            Keys.alphabetizeList: true,
        ])
        
        cancellable = NotificationCenter.default
            .publisher(for:  UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }
    
    // MARK: App Appearance Variables
    
    /**
     Which theme background to use for the app, system, light, or dark.
     */
    var themeBg: ThemeBackground {
        get {
            defaults.string(forKey: Keys.themeBg).flatMap {
                ThemeBackground(rawValue: $0)
            } ?? .system
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.themeBg)
        }
    }
    
    /**
     Which theme accent color to use for the app.
     */
    var themeAccent: ThemeAccent {
        get {
            defaults.string(forKey: Keys.themeAccent).flatMap {
                ThemeAccent(rawValue: $0)
            } ?? .purple
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.themeAccent)
        }
    }
    
    /**
     Which SF symbol name to use for the background layer of the task indicator.
     If the fill option is enabled, ".fill" will be appended to the end of the name when it is used.
     */
    var indicatorFrame: CompletionIndicatorFrame {
        get {
            defaults.string(forKey: Keys.indicatorFrame).flatMap {
                CompletionIndicatorFrame(rawValue: $0)
            } ?? .roundsquare
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.indicatorFrame)
        }
    }
    
    /**
     Which SF symbol name to use for the foreground layer of the task indicator when the
     corresponding task is completed. This symbol will be overlayed on top of and inside
     of the frame.
     */
    var indicatorSymbol: CompletionIndicatorSymbol {
        get {
            defaults.string(forKey: Keys.indicatorChecked).flatMap {
                CompletionIndicatorSymbol(rawValue: $0)
            } ?? .checkmark
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.indicatorChecked)
        }
    }
    
    /**
     Whether the indicator frame symbol name should have ".fill" appended to it so that the
     frame symbol is a filled shape.
     */
    var shouldFillIndicator: Bool {
        set { defaults.set(newValue, forKey: Keys.indicatorFill) }
        get { defaults.bool(forKey: Keys.indicatorFill) }
    }
    
    /**
     Which style of quick add button should be used in the `ListView` in order to add a
     new task.
     */
    var quickAddButtonStyle: QuickAddButtonStyle {
        get {
            defaults.string(forKey: Keys.quickAddButtonStyle).flatMap {
                QuickAddButtonStyle(rawValue: $0)
            } ?? .small
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.quickAddButtonStyle)
        }
    }
    
    // MARK: App Behavior Variables
    
    /**
     Whether app debugging is enabled.
     */
    var isDebugEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.debugEnabled) }
        get { defaults.bool(forKey: Keys.debugEnabled) }
    }
    
    /**
     Whether the app should deploy haptics.
     */
    var shouldUseHaptics: Bool {
        set { defaults.set(newValue, forKey: Keys.useHaptics) }
        get { defaults.bool(forKey: Keys.useHaptics) }
    }
    
    /**
     Whether a left-edge swipe on the `ListView` should open the `SettingsView`.
     */
    var shouldOpenSettingsOnLeftEdgeSlide: Bool {
        set { defaults.set(newValue, forKey: Keys.openSettingsOnLeftEdgeSlide) }
        get { defaults.bool(forKey: Keys.openSettingsOnLeftEdgeSlide) }
    }
    
    /**
     Whether text fields should be automatically focused when views appear such
     as `AddView` and `EditView`.
     */
    var shouldAutoFocusTextFields: Bool {
        set { defaults.set(newValue, forKey: Keys.autoFocusTextFields) }
        get { defaults.bool(forKey: Keys.autoFocusTextFields) }
    }
    
    // MARK: List Behavior Variables
    
    /**
     Whether task list items should alphabetized by their title.
     */
    var shouldAlphabetizeList: Bool {
        set { defaults.set(newValue, forKey: Keys.alphabetizeList) }
        get { defaults.bool(forKey: Keys.alphabetizeList) }
    }
    
    /**
     Whether task list items should be automatically deleted when checked off.
     */
    var shouldAutoDeleteTaskOnCheckoff: Bool {
        set { defaults.set(newValue, forKey: Keys.autoDeleteTaskOnCheckoff) }
        get { defaults.bool(forKey: Keys.autoDeleteTaskOnCheckoff) }
    }
}
