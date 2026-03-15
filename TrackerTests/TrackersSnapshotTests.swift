import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {
    
    func testTrackersViewController() {
        let trackerStore = TrackerStore()
        let categoryStore = TrackerCategoryStore()
        let recordStore = TrackerRecordStore()
        
        let trackersVC = TrackersViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
        
        trackersVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers_title", comment: ""),
            image: UIImage(resource: .trackersOff),
            selectedImage: UIImage(resource: .trackersOn)
        )
        
        let navigationController = UINavigationController(rootViewController: trackersVC)
        
        let tabBarController = TabBarController()
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics_title", comment: ""),
            image: UIImage(resource: .statisticsOff),
            selectedImage: UIImage(resource: .statisticsOn)
        )
        let statisticsNavController = UINavigationController(rootViewController: statisticsVC)
        
        tabBarController.viewControllers = [navigationController, statisticsNavController]
        
        _ = tabBarController.view
        
        assertSnapshot(of: tabBarController, as: .image, record: false)
    }
}
