import SwiftUI
import SwiftData

/*
 Subview of ListView which contains the layout for each individual task item, represented as a row of a List
 */
struct ListRowView: View {
    
    // MARK: Environment Variables
    @Environment(\.colorScheme)
    private var systemColorScheme
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject
    private var settings: SettingsStore
    
    @State
    private var showingSheet = false
    
    // MARK: Initialization
    private let task: TaskItem
    private let completedColor: Color
    private let lineLimit: Int
    private let truncated: Bool
    private let verticalPadding: CGFloat
    
    init(
        _ task: TaskItem,
        completedColor: Color = .accentColor,
        lineLimit: Int = 1,
        truncated: Bool = true,
        verticalPadding: CGFloat = 4
    ) {
        self.task = task
        self.completedColor = completedColor
        self.lineLimit = lineLimit
        self.truncated = truncated
        self.verticalPadding = verticalPadding
    }
    
    // MARK: Computed Variables
    private var textColor: Color {
        systemColorScheme == .dark ? .white : .black
    }
    
    private var shouldUseHaptics: Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    private var haptics: HapticGenerator {
        HapticGenerator(shouldUseHaptics)
    }
    
    // MARK: Layout Declaration
    public var body: some View {
        HStack {
            checkbox
                .onTapGesture {
                    task.isComplete.toggle()
                    try? context.save()
                    haptics.impact(.medium)
                }
            navLink
                .sheet(isPresented: $showingSheet) {
                    DisplayItemView(task: task)
                }
            Spacer()
        }
        .font(.title2)
        .padding(.vertical, verticalPadding)
    }
}

// MARK: Layout Components
extension ListRowView {
    
    /**
     Presents a CompletionIndicatorView, a custom checkbox view which supports user settings-derived
     customization options corresponding to the completion status of the associated task item model.
     */
    private var checkbox: some View {
        CompletionIndicatorView(
            isComplete: task.isComplete,
            symbolColor: .accentColor,
            fillCompleted: $settings.shouldFillIndicator.wrappedValue,
            frame: $settings.indicatorFrame.wrappedValue,
            indicator: $settings.indicatorSymbol.wrappedValue
        )
    }
    
    /**
     Presents a navigation-linked list item body which takes the user to the corresponding DisplayItemView.
     */
    private var navLink: some View {
        Button(action: {
            showingSheet.toggle()
            haptics.impact(.light)
        }) {
            Text(task.body)
                .fontWeight(.regular)
                .foregroundStyle(textColor)
                .lineLimit(3)
        }
    }
}

// MARK: Preview
#Preview {
    ListRowView(MockupUtilities.getMockTask())
        .previewLayout(.sizeThatFits)
        .environmentObject(SettingsStore())
}
