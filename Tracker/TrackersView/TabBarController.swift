import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Private Properties
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initializer
    init() {
        self.trackerStore = TrackerStore.shared
        self.categoryStore = TrackerCategoryStore.shared
        self.recordStore = TrackerRecordStore.shared
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
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
            title: "Трекеры",
            image: UIImage(resource: .trackersOff),
            selectedImage: UIImage(resource: .trackersOn)
        )
        
        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
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
