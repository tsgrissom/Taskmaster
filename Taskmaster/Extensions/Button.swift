import SwiftUI

extension Button {
    
    init(
        systemName: String,
        action: @escaping () -> Void
    ) {
        self.init("", systemImage: systemName, action: action)
    }
}
