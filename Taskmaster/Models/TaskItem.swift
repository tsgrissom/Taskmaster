import Foundation
import SwiftData

@Model
class TaskItem: Identifiable {
    
    var id:   String
    var body: String
    var isComplete: Bool
    
    var createdAt: Double
    var updatedAt: Double
    
    init(body: String, isComplete: Bool = false) {
        self.id = UUID().uuidString
        self.body = body
        self.isComplete = isComplete
        
        let now = Date().timeIntervalSince1970
        
        self.createdAt = now
        self.updatedAt = now
    }
}
