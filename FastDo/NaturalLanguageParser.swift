import Foundation

struct NaturalLanguageParser {
    static func parseTask(from text: String) -> (title: String, dueDate: Date?) {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        guard let detector = detector else {
            return (title: text.trimmingCharacters(in: .whitespacesAndNewlines), dueDate: nil)
        }
        
        let matches = detector.matches(in: text, options: [], range: range)
        
        guard let dateMatch = matches.first,
              let detectedDate = dateMatch.date else {
            return (title: text.trimmingCharacters(in: .whitespacesAndNewlines), dueDate: nil)
        }
        
        // Remove the detected date phrase from the title
        let nsString = text as NSString
        let beforeDate = nsString.substring(to: dateMatch.range.location)
        let afterDate = nsString.substring(from: dateMatch.range.location + dateMatch.range.length)
        let cleanedTitle = (beforeDate + " " + afterDate)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Only use dates in the future or today
        let calendar = Calendar.current
        let now = Date()
        let adjustedDate: Date
        
        if calendar.isDate(detectedDate, inSameDayAs: now) || detectedDate > now {
            adjustedDate = detectedDate
        } else {
            // If detected date is in the past, assume next occurrence
            if let nextYear = calendar.date(byAdding: .year, value: 1, to: detectedDate) {
                adjustedDate = nextYear
            } else {
                adjustedDate = detectedDate
            }
        }
        
        return (
            title: cleanedTitle.isEmpty ? text.trimmingCharacters(in: .whitespacesAndNewlines) : cleanedTitle,
            dueDate: adjustedDate
        )
    }
}