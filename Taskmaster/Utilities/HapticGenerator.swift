import UIKit

/**
 Instantiated in views to provide a series of methods which allow the developer to easily push haptic effects to the user.
 */
struct HapticGenerator {
    
    /**
     Whether the haptics should be played, most clearly to be provided the user's current haptic settings from the `SettingsStore`.
     */
    let shouldPlayOut: Bool
    
    init(_ shouldPlayOut: Bool = true) {
        self.shouldPlayOut = shouldPlayOut
    }
    
    /**
     Generates a UI impact of the supplied intensity and style.
     */
    func impact(
        _ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium,
        intensity: CGFloat = 1
    ) {
        if shouldPlayOut {
            UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity)
        }
    }
    
    /**
     Generates a UI feedback notification of the supplied type.
     */
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        if shouldPlayOut {
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }
}
