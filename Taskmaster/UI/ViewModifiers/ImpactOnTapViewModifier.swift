import SwiftUI

/// Adds a simultaneousGesture chain TapGesture to the modified view. On tap plays out an impact haptic with the supplied parameters.
struct ImpactOnTapViewModifier: ViewModifier {
    
    let playOut: Bool
    let impactType: UIImpactFeedbackGenerator.FeedbackStyle
    let intensity: CGFloat
    let haptics: HapticGenerator
    
    /**
     `playOut: Bool` Whether the haptic event should fire.
     `_ impactType: UIImpactFeedbackGenerator.FeedbackStyle` The style of impact to play out.
     `intensity: CGFloat` The intensity of the triggered haptic event.
     */
    init(playOut: Bool = true,
         _ impactType: UIImpactFeedbackGenerator.FeedbackStyle = .medium,
         intensity: CGFloat = 1) {
        self.playOut = playOut
        self.impactType = impactType
        self.intensity = intensity
        self.haptics = HapticGenerator(playOut)
    }
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        haptics.impact(impactType, intensity: intensity)
                    }
            )
    }
}
