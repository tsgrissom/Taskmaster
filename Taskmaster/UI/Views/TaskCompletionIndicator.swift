import SwiftUI

/// Represents a deeply customizable checkbox to be used within views which need to indicate a task's status as complete or incomplete.
struct TaskCompletionIndicator: View {
    
    // MARK: Environment Variables
    
    @Environment(\.colorScheme) var systemColorScheme
    
    // MARK: Constants

    let isComplete: Bool
    let symbolColor: Color
    let fillCompleted: Bool
    let frame: CompletionIndicatorFrame
    let indicator: CompletionIndicatorSymbol
    
    // MARK: Expressive Variables
    
    /**
     * Gets the appropriate foreground color for the system's light mode.
     */
    private var systemForegroundColor: Color {
        systemColorScheme == .dark ? .white : .black
    }
    
    /**
     * Gets the appropriate foreground color for text based on if the associated task is completed or not.
     * If completed, it uses the `symbolColor` provided on init. Otherwise it defers to the system foreground color.
     */
    var textColor: Color {
        isComplete ? symbolColor : systemForegroundColor
    }
    
    /**
     * Computes the system reference name of the appropriate SF symbol. This symbol is used as the frame in the background of
     * this view. If filling is enabled in the initializer, ".fill" is appended to the end of the system name.
     */
    var frameSymbolName: String {
        frame.getSymbolName() + ((fillCompleted && isComplete) ? ".fill" : "")
    }
    
    // MARK: Computed Variables
    
    /**
     * Calculates the amount of kerning required by the foreground symbol for the respective background symbol. Some specific
     * markers look off-center and can visually benefit from slight adjustments to their x and y positions.
     *
     * Returned in the form of a two-value tuple where `x` is the amount to be added to the x-value of the offset view modifier,
     * and `y` represents the amount to be added to the y-value of the offset view modifier.
     */
    var foregroundOffset: (x: CGFloat, y: CGFloat) {
        switch (frame) {
        case .diamond:
            if indicator != .checkmark {
                fallthrough
            } // This slight offset is only for checkmarks
            return (x: 0.8, y: 0.9)
        default:
            return (x: 0.0, y: 0.0)
        }
    }
    
    // MARK: Initialization
    
    init(
        isComplete: Bool = false,
        symbolColor: Color = .accentColor,
        fillCompleted: Bool = false,
        frame: CompletionIndicatorFrame = .roundsquare,
        indicator: CompletionIndicatorSymbol = .checkmark
    ) {
        self.isComplete = isComplete
        self.symbolColor = symbolColor
        self.fillCompleted = fillCompleted
        self.frame = frame
        self.indicator = indicator
    }
    
    // MARK: Layout Declaration
    
    var body: some View {
        let fgColor: Color = fillCompleted ? .white : textColor
        let fgOffset = foregroundOffset
        return ZStack {
            Image(systemName: frameSymbolName)
                .imageScale(.large)
                .foregroundStyle(textColor)
            
            if isComplete {
                Image(systemName: indicator.getSymbolName())
                    .imageScale(.small)
                    .offset(x: fgOffset.x, y: fgOffset.y)
                    .foregroundStyle(fgColor)
            }
        }
    }
}

// MARK: Previews

#Preview {
    VStack {
        TaskCompletionIndicator(isComplete: true)
        TaskCompletionIndicator(isComplete: true, fillCompleted: true)
        TaskCompletionIndicator()
        TaskCompletionIndicator(isComplete: true, frame: .circle, indicator: .xmark)
        TaskCompletionIndicator(isComplete: true, fillCompleted: true, frame: .circle, indicator: .xmark)
        TaskCompletionIndicator(frame: .circle, indicator: .xmark)
        TaskCompletionIndicator(isComplete: true, frame: .square)
        TaskCompletionIndicator(isComplete: true, fillCompleted: true, frame: .square)
        TaskCompletionIndicator(frame: .square)
        TaskCompletionIndicator(isComplete: true, frame: .app)
        TaskCompletionIndicator(isComplete: true, fillCompleted: true, frame: .app)
        TaskCompletionIndicator(frame: .app)
        TaskCompletionIndicator(isComplete: true, frame: .diamond)
        TaskCompletionIndicator(isComplete: true, fillCompleted: true, frame: .diamond)
        TaskCompletionIndicator(frame: .diamond)
        TaskCompletionIndicator(isComplete: true, frame: .roundsquare)
        TaskCompletionIndicator(isComplete: true, fillCompleted: true, frame: .roundsquare)
        TaskCompletionIndicator(frame: .roundsquare)
    }
}
