import Foundation

enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var shortName: String {
        switch self {
        case .sunday: return NSLocalizedString("sunday_short", comment: "Sunday short name")
        case .monday: return NSLocalizedString("monday_short", comment: "Monday short name")
        case .tuesday: return NSLocalizedString("tuesday_short", comment: "Tuesday short name")
        case .wednesday: return NSLocalizedString("wednesday_short", comment: "Wednesday short name")
        case .thursday: return NSLocalizedString("thursday_short", comment: "Thursday short name")
        case .friday: return NSLocalizedString("friday_short", comment: "Friday short name")
        case .saturday: return NSLocalizedString("saturday_short", comment: "Saturday short name")
        }
    }
    
    var fullName: String {
        switch self {
        case .sunday: return NSLocalizedString("sunday_full", comment: "Sunday full name")
        case .monday: return NSLocalizedString("monday_full", comment: "Monday full name")
        case .tuesday: return NSLocalizedString("tuesday_full", comment: "Tuesday full name")
        case .wednesday: return NSLocalizedString("wednesday_full", comment: "Wednesday full name")
        case .thursday: return NSLocalizedString("thursday_full", comment: "Thursday full name")
        case .friday: return NSLocalizedString("friday_full", comment: "Friday full name")
        case .saturday: return NSLocalizedString("saturday_full", comment: "Saturday full name")
        }
    }
    
    static func from(_ weekdayNumber: Int) -> Weekday? {
        return Weekday(rawValue: weekdayNumber)
    }
}
