import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhiteDay
        title = NSLocalizedString("statistics_title", comment: "Statistics screen title")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
