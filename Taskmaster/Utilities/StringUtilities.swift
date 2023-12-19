import Foundation

struct StringUtilities {
    
    /**
     Takes an array and a noun and builds a count string which is a plural,
     capitalization-friendly string represented the amount in the array.
     Examples: "No tasks", "0 Tasks", "1 Task", "2 Tasks", etc. where task can be substituted
     for any word.
     `capitalize: Bool = true` If the first word should be capitalized.
     `pluralize: String = true` If plural array count strings should have an "s" appended to them. 0 and anything greater than 1.
     `overrideEmpty: String? = nil` If the array is empty and this String is supplied, it will replace any count string.
     */
    static func createCountString(
        _ noun: String, arr: [Any],
        capitalize: Bool = true, pluralize: Bool = true,
        overrideEmpty: String? = nil) -> String {
        if arr.isEmpty && overrideEmpty != nil {
            return overrideEmpty!
        }
        
        let count = arr.count
        var modifiedNoun = String()
        let leadingChar = noun.prefix(1)
        
        let index = noun.index(noun.startIndex, offsetBy: 1)
        let remaining = noun[index...]
        
        modifiedNoun += capitalize ? String(leadingChar).uppercased() : String(leadingChar)
        modifiedNoun += remaining
        
        if (count > 1 || count == 0) && pluralize {
            modifiedNoun += "s"
        }
        
        return "\(count) \(modifiedNoun)"
    }

}
