import Foundation
import SwiftData

@Model
class TaskItem: Identifiable {
    
    var id: String
    var body: String
    var isComplete: Bool
    
    init(body: String, isComplete: Bool = false) {
        self.id = UUID().uuidString
        self.body = body
        self.isComplete = isComplete
    }
}
