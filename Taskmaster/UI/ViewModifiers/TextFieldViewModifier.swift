import SwiftUI

struct TextFieldViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(height: 45)
            .background(Color.textField.gradient)
            .cornerRadius(10)
    }
}
