import Foundation

final class StatisticsStorage {
    static let shared = StatisticsStorage()
    
    private let bestPeriodKey = "best_period"
    private let perfectDaysKey = "perfect_days"
    private let completedTrackersKey = "completed_trackers"
    private let averageValueKey = "average_value"
    
    private init() {}
    
    var bestPeriod: Int {
        get { UserDefaults.standard.integer(forKey: bestPeriodKey) }
        set { UserDefaults.standard.set(newValue, forKey: bestPeriodKey) }
    }
    
    var perfectDays: Int {
        get { UserDefaults.standard.integer(forKey: perfectDaysKey) }
        set { UserDefaults.standard.set(newValue, forKey: perfectDaysKey) }
    }
    
    var completedCount: Int {
        get { UserDefaults.standard.integer(forKey: completedTrackersKey) }
        set { UserDefaults.standard.set(newValue, forKey: completedTrackersKey) }
    }
    
    var averageValue: Double {
        get { UserDefaults.standard.double(forKey: averageValueKey) }
        set { UserDefaults.standard.set(newValue, forKey: averageValueKey) }
    }
}
