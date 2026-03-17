import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys
    private enum Key {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let completedTrackersCount = "completed_trackers_count"
        static let bestPeriod = "best_period"
        static let perfectDays = "perfect_days"
        static let averageValue = "average_value"
        static let selectedFilter = "selected_filter"
    }
    
    // MARK: - Onboarding
    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }
    
    // MARK: - Statistics
    var completedTrackersCount: Int {
        get { defaults.integer(forKey: Key.completedTrackersCount) }
        set { defaults.set(newValue, forKey: Key.completedTrackersCount) }
    }
    
    var bestPeriod: Int {
        get { defaults.integer(forKey: Key.bestPeriod) }
        set { defaults.set(newValue, forKey: Key.bestPeriod) }
    }
    
    var perfectDays: Int {
        get { defaults.integer(forKey: Key.perfectDays) }
        set { defaults.set(newValue, forKey: Key.perfectDays) }
    }
    
    var averageValue: Double {
        get { defaults.double(forKey: Key.averageValue) }
        set { defaults.set(newValue, forKey: Key.averageValue) }
    }
    
    // MARK: - Filters
    var selectedFilter: Int {
        get { defaults.integer(forKey: Key.selectedFilter) }
        set { defaults.set(newValue, forKey: Key.selectedFilter) }
    }
    
    // MARK: - Reset
    func resetAll() {
        defaults.removeObject(forKey: Key.hasSeenOnboarding)
        defaults.removeObject(forKey: Key.completedTrackersCount)
        defaults.removeObject(forKey: Key.bestPeriod)
        defaults.removeObject(forKey: Key.perfectDays)
        defaults.removeObject(forKey: Key.averageValue)
        defaults.removeObject(forKey: Key.selectedFilter)
    }
}
