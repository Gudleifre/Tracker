import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhiteDay
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
