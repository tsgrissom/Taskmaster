import Foundation

/// Represents available lighting themes such as dark, light, and abiding the current system setting.
public enum ThemeBackgroundOption: String, CaseIterable {
    case dark
    case system
    case light
}

/// Represents available accent colors for Taskmaster.
public enum ThemeAccentOption: String, CaseIterable {
    case purple
    case blue
}
