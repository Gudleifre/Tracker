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
        case .sunday: "Вс"
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        }
    }
    
    var fullName: String {
        switch self {
        case .sunday: "Воскресенье"
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        }
    }
    
    static func from(_ weekdayNumber: Int) -> Weekday? {
        return Weekday(rawValue: weekdayNumber)
    }
}
