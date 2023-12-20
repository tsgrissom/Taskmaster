import SwiftUI
import SwiftData

/// The task list view composed of many ListRowViews
struct DisplayTaskListPage: View {
    
    // MARK: Environment Variables
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject
    private var settings: SettingsStore
    
    @Query
    private var tasks: [TaskItem]
    
    // MARK: Computed Variables
    
    /**
     Checks if haptics are enabled via app settings
     */
    private var shouldUseHaptics: Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    private var haptics: HapticGenerator {
        HapticGenerator(shouldUseHaptics)
    }
    
    private var navigationTitle: String {
        StringUtilities.createCountString("Task", arr: tasks, capitalize: true, pluralize: true, overrideEmpty: "Taskmaster")
    }
    
    private var leadingNavButton: some View {
        NavigationLink(destination: SettingsPage()) {
            Image(systemName: "gear")
        }
        .modifier(ImpactOnTapViewModifier(playOut: shouldUseHaptics, .light))
    }
    
    @ViewBuilder
    private var trailingNavButton: some View {
        if tasks.isEmpty {
            EmptyView()
        } else {
            EditButton()
                .foregroundStyle(Color.accentColor)
        }
    }
    
    // MARK: Body Start
    public var body: some View {
        VStack {
            foregroundLayer
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        leadingNavButton
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        trailingNavButton
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Spacer()
                            quickAddButton
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .bottomBar)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: Superlayouts
    
    /**
     Presents most of the content for this view.
     */
    private var foregroundLayer: some View {
        return VStack {
            if tasks.isEmpty {
                Spacer()
                OnboardingSection()
            } else {
                listLayer
            }
        }
    }
    
    // MARK: List Functions
    
    private func deleteTask(_ task: TaskItem) {
        context.delete(task)
        try? context.save()
    }
    
    private func duplicateTask(_ task: TaskItem) {
        let model = TaskItem(body: task.body, isComplete: task.isComplete)
        context.insert(model)
    }
    
    private func moveTask() {
        // TODO Move task logic
    }
    
    // MARK: Event Functions
    
    /**
     Invoked when a ListRowView in the list is swiped from left to right
     */
    private func onSwipeLeadingEdge(_ task: TaskItem) -> some View {
        Button(task.isComplete ? "Undo Complete" : "Complete") {
            task.isComplete.toggle()
            try? context.save()
        }
        .tint(task.isComplete ? .red : .green)
    }
    
    /**
     Available when long pressing a list item.
     Copy item's title to system clipboard.
     */
    private func contextMenuButtonCopy(_ task: TaskItem) -> some View {
        func onPress() {
            UIPasteboard.general.string = task.body
            haptics.notification()
        }
        
        return Button(action: onPress) {
            Label("Copy", systemImage: "clipboard")
        }
    }
    
    /**
     Available when long pressing a list item.
     Navigate to the EditView for the respective list item.
     */
    private func contextMenuButtonEdit(_ task: TaskItem) -> some View {
        NavigationLink(destination: EditTaskPage(task: task)) {
            Label("Edit", systemImage: "pencil")
        }
        .modifier(ImpactOnTapViewModifier(playOut: shouldUseHaptics, .medium))
    }
    
    /**
     Available when long pressing a list item.
     Duplicates the respective list item.
     */
    private func contextMenuButtonDuplicate(_ task: TaskItem) -> some View {
        func onPress() {
            haptics.notification()
            withAnimation(.linear) {
                duplicateTask(task)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                haptics.notification()
            }
        }
        
        return Button(action: onPress) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
    }
    
    /**
     Available when long pressing a list item.
     Offers a share sheet for the respective list item.
     */
    private func contextMenuButtonShare(_ task: TaskItem) -> some View {
        func onPress() {
            // TODO Offer a share sheet for the provided ItemModel
            haptics.impact(.medium)
        }
        
        return Button(action: onPress) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }
    
    /**
     Available when long pressing a list item.
     Deletes the respective list item from the view model.
     */
    private func contextMenuButtonDelete(_ task: TaskItem) -> some View {
        func onPress() {
            withAnimation(.linear) {
                deleteTask(task)
            }
            haptics.notification()
        }
        
        return Button(role: .destructive, action: onPress) {
            Label("Delete task", systemImage: "trash")
        }
    }
}

// MARK: Layout Declarations

extension DisplayTaskListPage {
    
    /**
     Presents a row of the List view, one of which corresponds to one task. Offers many context menu
     and swipe actions attached to the particular task reference.
     */
    private func listRow(_ task: TaskItem) -> some View {
        ListRow(task)
            .contextMenu {
                contextMenuButtonCopy(task)
                contextMenuButtonDuplicate(task)
                contextMenuButtonEdit(task)
                contextMenuButtonShare(task)
                contextMenuButtonDelete(task)
            }
            .swipeActions(edge: .leading) {
                onSwipeLeadingEdge(task)
            }
    }
    
    /**
     Presents the task items view model in the form of a List view.
     Can contain many ListRowViews which have various context menu and swipe actions attached to them.
     */
    private var listLayer: some View {
        List {
            ForEach(tasks) { task in
                listRow(task)
            }
            .onDelete { indices in
                for index in indices {
                    deleteTask(tasks[index])
                }
            }
//            .onMove(perform: moveTask) TODO Move logic
        }
    }
    
    @ViewBuilder
    private var quickAddButton: some View {
        let hapticModifier = ImpactOnTapViewModifier(playOut: shouldUseHaptics, .light)
        
        switch ($settings.quickAddButtonStyle.wrappedValue) {
        case .large:
            NavigationLink(destination: AddTaskPage()) {
                QuickAddTaskButton(size: 110)
            }
            .modifier(hapticModifier)
            .offset(x: 30)
//          .offset(x: 20, y: 50)
        case .small:
            NavigationLink(
                destination: AddTaskPage()
            ) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(Color.accentColor)
            }
            .modifier(hapticModifier)
        case .material:
            NavigationLink(destination: AddTaskPage()) {
                QuickAddTaskButton(size: 55)
            }
            .modifier(hapticModifier)
//            .padding(.bottom, 15)
//            .offset(y: 10)
        }
    }
}

/*
 Subview of ListView which contains the layout for each individual task item, represented as a row of a List
 */
private struct ListRow: View {
    
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
                    DisplayTaskItemPage(task: task)
                }
            Spacer()
        }
        .font(.title2)
        .padding(.vertical, verticalPadding)
    }
}

extension ListRow {
    
    /**
     Presents a CompletionIndicatorView, a custom checkbox view which supports user settings-derived
     customization options corresponding to the completion status of the associated task item model.
     */
    private var checkbox: some View {
        TaskCompletionIndicator(
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

/**
 * Displayed when there are no tasks in the view model.
 * Slides in from below when visible.
 */
private struct OnboardingSection: View {
    
    // MARK: Environment Variables
    @EnvironmentObject
    private var settings: SettingsStore
    
    // MARK: Constants
    private let noItemsBlob   = "Looking to organize your life? Taskmaster can help with that. Press the big purple button below to begin composing your first task."
    private let blobPadding   = DeviceUtilities.isPhone() ? 30.0 : 200.0
    private let initialOffset = -300.0
    private let animateOffset = DeviceUtilities.isTablet() ? -400.0 : -100.0
    
    // MARK: Stateful Variables
    @State var animate = false
    
    public var body: some View {
        VStack(spacing: 0) {
            sectionBlob
            sectionPromptAndButton
                .padding(.top, 25)
        }
        .offset(y: animate ? (initialOffset + animateOffset) : initialOffset)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.75)) {
                    animate = true
                }
            }
        }
    }
}

// MARK: Layout Declarations
extension OnboardingSection {
    
    // MARK: Superviews
    
    private var sectionBlob: some View {
        VStack {
            Text(noItemsBlob)
                .multilineTextAlignment(.center)
                .padding(.horizontal, blobPadding)
        }
    }
    
    private var sectionPromptAndButton: some View {
        VStack(spacing: 0) {
            Text("Ready to get started? ⬇️")
                .font(.caption)
            buttonBeginComposing
                .padding(.horizontal)
                .padding(.bottom, 50)
                .padding(.top, 10)
                .modifier(HapticOnTapViewModifier(playOut: $settings.shouldUseHaptics.wrappedValue))
        }
    }
    
    // MARK: Subviews
    
    private var buttonBeginComposing: some View {
        NavigationLink(
            destination: AddTaskPage(),
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor)
                        .frame(height: 55)
                        .frame(maxWidth: 200)
                        .shadow(radius: 25, y: 15)
                    Text("Begin Composing")
                        .foregroundColor(.white)
                        .font(.headline)
                        .transition(.move(edge: .leading))
                }
            }
        )
    }
}

// MARK: Previews

#Preview {
    NavigationStack {
        DisplayTaskListPage()
    }
    .environmentObject(SettingsStore())
}

#Preview("OnboardingSection") {
    OnboardingSection()
        .environmentObject(SettingsStore())
        .padding(.top, 500)
}

