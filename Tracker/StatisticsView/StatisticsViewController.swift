import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Private Properties
    private let viewModel = StatisticsViewModel()
    
    private var statsItems: [(value: String, title: String)] = [
        (value: "0", title: NSLocalizedString("best_period", comment: "Best period")),
        (value: "0", title: NSLocalizedString("perfect_days", comment: "Perfect days")),
        (value: "0", title: NSLocalizedString("completed_trackers", comment: "Completed trackers")),
        (value: "0", title: NSLocalizedString("average_value", comment: "Average value"))
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlaceholder()
        bindViewModel()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatisticsUpdate),
            name: .statisticsDidUpdate,
            object: nil
        )
        
        viewModel.loadStats()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        
        title = NSLocalizedString("statistics_title", comment: "Statistics screen title")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let topOffset: CGFloat = UIScreen.main.bounds.height <= 667 ? 16 : 77
        
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topOffset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupPlaceholder() {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .statisticsPlaceholder)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = NSLocalizedString("statistics_empty", comment: "No statistics yet")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderView.addSubview(imageView)
        placeholderView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor, constant: -16),
            label.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onStatsUpdated = { [weak self] bestPeriod, perfectDays, completedCount, averageValue in
            self?.updateStats(
                bestPeriod: bestPeriod,
                perfectDays: perfectDays,
                completedCount: completedCount,
                averageValue: averageValue
            )
            self?.tableView.reloadData()
        }
        
        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            self?.tableView.isHidden = isEmpty
            self?.placeholderView.isHidden = !isEmpty
        }
    }
    
    private func updateStats(bestPeriod: Int, perfectDays: Int, completedCount: Int, averageValue: Double) {
        statsItems = [
            (value: "\(bestPeriod)", title: NSLocalizedString("best_period", comment: "Best period")),
            (value: "\(perfectDays)", title: NSLocalizedString("perfect_days", comment: "Perfect days")),
            (value: "\(completedCount)", title: NSLocalizedString("completed_trackers", comment: "Completed trackers")),
            (value: "\(Int(averageValue))", title: NSLocalizedString("average_value", comment: "Average value"))
        ]
    }
    
    // MARK: - @objc Methods
    @objc private func handleStatisticsUpdate() {
        viewModel.loadStats()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Extensions
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.identifier, for: indexPath) as? StatisticsCell else {
            return UITableViewCell()
        }
        
        let item = statsItems[indexPath.row]
        cell.configure(value: item.value, title: item.title)
        
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
