import SwiftUI

struct TaskPreviewBoxSection: View {

    let isTextPrepared: Bool
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
            VStack {
                headerRow
                    .padding(.top)
                    .padding(.horizontal)
                textRow
                    .padding(.bottom)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: 125)
    }
}

extension TaskPreviewBoxSection {
    
    private var headerRow: some View {
        let title = Text("Task Preview:")
        let symbolColor: Color = isTextPrepared ? .green : .red
        let symbolName = isTextPrepared ? "checkmark" : "xmark"
        let kerning = isTextPrepared ? 0.0 : -0.3
        
        var indicator: some View {
            ZStack {
                Image(systemName: "circle.fill")
                    .imageScale(.large)
                Image(systemName: symbolName)
                    .imageScale(.small)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .offset(x: kerning)
            }
        }
        
        return HStack {
            title
                .font(.title2)
            indicator
                .foregroundStyle(symbolColor)
            Spacer()
        }
    }
    
    private var textRow: some View {
        HStack {
            Text(text)
                .padding(.horizontal, 2)
            Spacer()
        }
    }
}

#Preview {
    VStack {
        TaskPreviewBoxSection(isTextPrepared: true, text: "Lorem ipsum dolor")
        TaskPreviewBoxSection(isTextPrepared: false, text: "Lorem ipsum dolor")
    }
}
