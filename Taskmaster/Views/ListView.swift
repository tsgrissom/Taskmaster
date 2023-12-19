import SwiftUI
import SwiftData

/// The task list view composed of many ListRowViews
struct ListView: View {
    
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
        NavigationLink(destination: SettingsView()) {
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
                OnboardingView()
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
        NavigationLink(destination: EditView(task: task)) {
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

extension ListView {
    
    /**
     Presents a row of the List view, one of which corresponds to one task. Offers many context menu
     and swipe actions attached to the particular task reference.
     */
    private func listRow(_ task: TaskItem) -> some View {
        ListRowView(task)
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
            NavigationLink(destination: AddView()) {
                QuickAddButtonView(size: 110)
            }
            .modifier(hapticModifier)
            .offset(x: 30)
//          .offset(x: 20, y: 50)
        case .small:
            NavigationLink(
                destination: AddView()
            ) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(Color.accentColor)
            }
            .modifier(hapticModifier)
        case .material:
            NavigationLink(destination: AddView()) {
                QuickAddButtonView(size: 55)
            }
            .modifier(hapticModifier)
//            .padding(.bottom, 15)
//            .offset(y: 10)
        }
    }
}

// MARK: Preview

#Preview {
    NavigationStack {
        ListView()
    }
    .environmentObject(SettingsStore())
}
