import Foundation

enum DateFormatOption: String, CaseIterable {
    
    case american = "MM'/'dd'/'yyyy"
    case international = "yyyy'-'MM'-'dd"
    
    func getFormat() -> DateFormatter {
        let format = DateFormatter()
        format.dateFormat = self.rawValue
        return format
    }
}
