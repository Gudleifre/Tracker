import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
//        let storyboard = UIStoryboard(name: "Main", bundle: .main)
//        
//        let imagesListViewController = storyboard.instantiateViewController(
//            withIdentifier: "ImagesListViewController"
//        ) as! ImagesListViewController
//        let imagesListPresenter = ImagesListPresenter()
//        imagesListViewController.configure(imagesListPresenter)
//        
//        imagesListViewController.tabBarItem = UITabBarItem(
//            title: "",
//            image: UIImage(named: "mainNoActive"),
//            selectedImage: UIImage(named: "mainActive")
//        )
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackersOff),
            selectedImage: UIImage(resource: .trackersOn)
        )
        
        let statisticsViewController = StatisticsViewController()
        
//        let profilePresenter = ProfilePresenter()
//        profileViewController.configure(profilePresenter)
        
        // TODO: тут остановился и не забудь сделать коммит начальный
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "profileNoActive"),
            selectedImage: UIImage(named: "profileActive")
        )
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlackIOS
        tabBar.standardAppearance = appearance
        
        self.viewControllers = [trackersViewController, profileViewController]
    }
}
