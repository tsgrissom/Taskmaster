import Foundation

/// Provides a series of methods which help in mocking up previews.
struct MockupUtilities {
    
    /**
     Gets a random title for a mockup ItemModel.
     */
    private static func getRandomItemTitle() -> String {
        let mockTasks = ["A task list item!", "Another dummy task item", 
                         "Something to do, something to fix", "This is an example of a task list item",
                         "Yet another task item for the mockup"]
        return mockTasks.randomElement() ?? "Lorem ipsum dolor"
    }
    
    /**
     Mocks up an ItemModel which will by default by randomized. You can override the `title` and `isCompleted` properties.
     */
    public static func getMockTask(
        body: String = getRandomItemTitle(),
        isComplete: Bool = Bool.random()
    ) -> TaskItem {
        return TaskItem(body: body, isComplete: isComplete)
    }
}
