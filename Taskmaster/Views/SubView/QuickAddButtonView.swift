import SwiftUI

// MARK: ButtonStyle
/// A custom ButtonStyle to be applied exclusively within the QuickAddButtonView. Customizes the active color.
private struct CustomButtonStyle: ButtonStyle {
    
    let activeColor: Color
    let defaultColor: Color
    let frameSize: CGFloat

    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: AddView()) {
            configuration.label
                .frame(width: frameSize, height: frameSize)
                .background(configuration.isPressed ? activeColor : defaultColor)
                .clipShape(Circle())
                .foregroundColor(.white)
                .animation(.easeInOut, value: configuration.isPressed)
        }
        .simultaneousGesture(TapGesture()
            .onEnded { _ in
                isPressed.toggle()
            }
        )
    }
}

/// Represents a circular button which contains a proportionally sized plus symbol overlayed on top of it.
struct QuickAddButtonView: View {
    
    // MARK: Constants
    let frameSize: CGFloat
    let symbolMultiplier: CGFloat
    let fillColor: Color
    let activeColor: Color
    
    // MARK: Stateful Variables
    @State private var isPressed = false

    // MARK: Initialization
    init(size frameSize: CGFloat = 150,
         fgMultiplier symbolMultiplier: CGFloat = 0.45,
         fill fillColor: Color = .accentColor,
         pressed activeColor: Color = .lightPurple
    ) {
        self.frameSize = frameSize
        self.fillColor = fillColor
        self.symbolMultiplier = symbolMultiplier
        self.activeColor = activeColor
    }
    
    // MARK: Layout Declaration
    var body: some View {
        let buttonStyle = CustomButtonStyle(
            activeColor: activeColor,
            defaultColor: fillColor,
            frameSize: frameSize,
            isPressed: $isPressed)
        return Button(action: {}) {
            Image(systemName: "plus")
                .foregroundStyle(.white)
                .font(.system(size: frameSize * symbolMultiplier))
                .fontWeight(.heavy)
        }
        .buttonStyle(buttonStyle)
    }
}

// MARK: Previews
#Preview {
    VStack {
        HStack {
            Text("Size 150")
            QuickAddButtonView(size: 150)
        }
        HStack {
            Text("Size 125")
            QuickAddButtonView(size: 125)
        }
        HStack {
            Text("Size 100")
            QuickAddButtonView(size: 100)
        }
        HStack {
            Text("Size 75")
            QuickAddButtonView(size: 75)
        }
        HStack {
            Text("Size 50")
            QuickAddButtonView(size: 50)
        }
        HStack {
            Text("Size 25")
            QuickAddButtonView(size: 25)
        }
    }
}
