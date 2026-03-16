import Foundation

final class StatisticsViewModel {
    // MARK: - Callbacks
    var onStatsUpdated: ((Int, Int, Int, Double) -> Void)?
    var onEmptyStateChanged: ((Bool) -> Void)?
    
    // MARK: - Private Properties
    private let storage = StatisticsStorage.shared
    
    // MARK: - Public Methods
    func loadStats() {
        let hasData = storage.completedCount > 0
        onStatsUpdated?(storage.bestPeriod, storage.perfectDays,
                        storage.completedCount, storage.averageValue)
        onEmptyStateChanged?(!hasData)
    }
}
