import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    // MARK: - Private Methods
    private func setupViewControllers() {
        let trackersViewController = TrackersViewController()
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
