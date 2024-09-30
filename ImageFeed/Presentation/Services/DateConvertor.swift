import Foundation

// MARK: - DateConvertor

final class DateConvertor {
    static let shared = DateConvertor()
    
// MARK: - Private Properties
    
    private init() { }
    
    private let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale.autoupdatingCurrent
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private let dateFormatter = ISO8601DateFormatter()
    
// MARK: - Public Methods
    
    func getDateFromString(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
    
    func getStringFromDate(from date: Date) -> String {
        var dateString = longDateFormatter.string(from: date)
        dateString = dateString.replacingOccurrences(of: "г.", with: "")
        return dateString
    }
}
