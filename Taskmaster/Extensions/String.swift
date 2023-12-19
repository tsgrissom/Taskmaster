import Foundation

extension String {
    
    func trim() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var isNotEmpty: Bool {
        !self.isEmpty
    }
}
