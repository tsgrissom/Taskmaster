import SwiftUI

struct ControlRowButtonViewModifier: ViewModifier {
    
    let height: CGFloat
    
    init(height: CGFloat = 45.0) {
        self.height = height
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .imageScale(.large)
            .frame(height: height)
            .frame(maxWidth: .infinity)
    }
}
