import SwiftUI

extension Color {
    /// Access the color theme assets anywhere in the project.
    static let theme = ColorTheme()
    
    static let lightPurple = Color("LightPurple")
    static let offWhite    = Color("OffWhite")
    static let danger      = Color("Danger")
    static let textField   = Color("TextField")
    
    /// Initializer to access `UIColor` named colors.
    init?(named name: String) {
        guard let color = UIColor(named: name) else {
            return nil
        }
        
        self.init(color)
    }
    
    /**
     Shortcut which lets you provide a Tuple of three Doubles representing the red, green, and blue values
     of a color space.
     Simpler to invoke than `Color#init(r: xr / 255, g: xg / 255, b: xb / 255)`
     */
    init(rgb: (r: Double, g: Double, b: Double)) {
        self.init(red: rgb.r / 255, green: rgb.g / 255, blue: rgb.b / 255)
    }
}

/// Pulls color assets from asset catalog to be used as constants within views.
struct ColorTheme {
    let accent    = Color("AccentColor")
}
