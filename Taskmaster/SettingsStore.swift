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
        static let dateFormat = "DateFormat"
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
            Keys.themeBg: ThemeBackgroundOption.system.rawValue,
            Keys.themeAccent: ThemeAccentOption.purple.rawValue,
            Keys.indicatorFrame: CompletionIndicatorFrameOption.roundsquare.rawValue,
            Keys.indicatorChecked: CompletionIndicatorSymbolOption.checkmark.rawValue,
            Keys.indicatorFill: false,
            Keys.quickAddButtonStyle: QuickAddButtonStyleOption.small.rawValue,
            Keys.dateFormat: DateFormatOption.international.rawValue,
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
    var themeBg: ThemeBackgroundOption {
        get {
            defaults.string(forKey: Keys.themeBg).flatMap {
                ThemeBackgroundOption(rawValue: $0)
            } ?? .system
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.themeBg)
        }
    }
    
    /**
     Which theme accent color to use for the app.
     */
    var themeAccent: ThemeAccentOption {
        get {
            defaults.string(forKey: Keys.themeAccent).flatMap {
                ThemeAccentOption(rawValue: $0)
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
    var indicatorFrame: CompletionIndicatorFrameOption {
        get {
            defaults.string(forKey: Keys.indicatorFrame).flatMap {
                CompletionIndicatorFrameOption(rawValue: $0)
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
    var indicatorSymbol: CompletionIndicatorSymbolOption {
        get {
            defaults.string(forKey: Keys.indicatorChecked).flatMap {
                CompletionIndicatorSymbolOption(rawValue: $0)
            } ?? .checkmark
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.indicatorChecked)
        }
    }
    
    var dateFormat: DateFormatOption {
        get {
            defaults.string(forKey: Keys.dateFormat).flatMap {
                DateFormatOption(rawValue: $0)
            } ?? .international
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.dateFormat)
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
    var quickAddButtonStyle: QuickAddButtonStyleOption {
        get {
            defaults.string(forKey: Keys.quickAddButtonStyle).flatMap {
                QuickAddButtonStyleOption(rawValue: $0)
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
