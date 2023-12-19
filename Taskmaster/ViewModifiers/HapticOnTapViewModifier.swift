import SwiftUI

/// Adds a simultaneousGesture chain TapGesture to the modified view. On tap plays out a notification feedback haptic with the supplied parameters.
struct HapticOnTapViewModifier: ViewModifier {
    
    let playOut: Bool
    let feedbackType: UINotificationFeedbackGenerator.FeedbackType
    let haptics: HapticGenerator
    
    /**
     `playOut: Bool` Whether the haptic event should fire.
     `_ feedbackType: UINotificationFeedbackGenerator.FeedbackType` The type of feedback to play out.
     */
    init(playOut: Bool = true,
         _ feedbackType: UINotificationFeedbackGenerator.FeedbackType = .success) {
        self.playOut = playOut
        self.feedbackType = feedbackType
        self.haptics = HapticGenerator(playOut)
    }
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        haptics.notification(feedbackType)
                    }
            )
    }
}
