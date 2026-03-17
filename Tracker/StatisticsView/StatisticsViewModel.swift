import Foundation

final class StatisticsViewModel {
    // MARK: - Callbacks
    var onStatsUpdated: ((Int, Int, Int, Double) -> Void)?
    var onEmptyStateChanged: ((Bool) -> Void)?
    
    // MARK: - Private Properties
    private let storage = UserDefaultsService.shared
    
    // MARK: - Public Methods
    func loadStats() {
        let hasData = storage.completedTrackersCount > 0
        onStatsUpdated?(storage.bestPeriod, storage.perfectDays,
                        storage.completedTrackersCount, storage.averageValue)
        onEmptyStateChanged?(!hasData)
    }
}
