import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all = 0        
    case today = 1
    case completed = 2
    case uncompleted = 3
    
    var title: String {
        switch self {
        case .all: return NSLocalizedString("filter_all", comment: "All trackers")
        case .today: return NSLocalizedString("filter_today", comment: "Trackers for today")
        case .completed: return NSLocalizedString("filter_completed", comment: "Completed")
        case .uncompleted: return NSLocalizedString("filter_uncompleted", comment: "Uncompleted")
        }
    }
}
