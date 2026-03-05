import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Private Properties
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    // MARK: - Private Methods
    private func setupViewControllers() {
        let trackersViewController = TrackersViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore)
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers_title", comment: "Trackers tab title"),
            image: UIImage(resource: .trackersOff),
            selectedImage: UIImage(resource: .trackersOn)
        )
        
        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics_title", comment: "Statistics tab title"),
            image: UIImage(resource: .statisticsOff),
            selectedImage: UIImage(resource: .statisticsOn)
        )
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhiteDay
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.2)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
