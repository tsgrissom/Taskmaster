import Foundation

/// Represents various symbols within Apple's SF icon sets which are used as framing in the background of CompletionIndicatorViews.
enum CompletionIndicatorFrameOption: String, CaseIterable {
    case app, circle, diamond, roundsquare, square
    
    func getSymbolName() -> String {
        switch self {
        case .app:
            return "app"
        case .circle:
            return "circle"
        case .diamond:
            return "diamond"
        case .roundsquare:
            return "square"
        case .square:
            return "squareshape"
        }
    }
}

/// Represents various symbols within Apple's SF icon sets which are used as the completion marker within the foreground of CompletionIndicatorViews.
enum CompletionIndicatorSymbolOption: String, CaseIterable {
    case asterisk, checkmark, scribble, xmark
    
    func getSymbolName() -> String {
        switch self {
        case .asterisk:
            return "asterisk"
        case .checkmark:
            return "checkmark"
        case .scribble:
            return "scribble.variable"
        case .xmark:
            return "xmark"
        }
    }
}

