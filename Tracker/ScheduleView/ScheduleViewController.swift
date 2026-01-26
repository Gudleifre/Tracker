import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: [Weekday])
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - Private Properties
    private var selectedDays: [Weekday] = []
    private let weekdays: [Weekday] = [
        .monday, .tuesday, .wednesday,
        .thursday, .friday, .saturday, .sunday
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weekdayCell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        
        title = "Расписание"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - @objc Methods
    @objc private func doneButtonTapped() {
        delegate?.didSelectSchedule(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let selectedWeekday = weekdays[sender.tag]
        
        if sender.isOn {
            if !selectedDays.contains(selectedWeekday) {
                selectedDays.append(selectedWeekday)
            }
        } else {
            selectedDays.removeAll { $0 == selectedWeekday }
        }
        selectedDays.sort { $0.rawValue < $1.rawValue }
    }
}

// MARK: - Extensions
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekdayCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        
        let weekday = weekdays[indexPath.row]
        
        let dayLabel = UILabel()
        dayLabel.text = weekday.fullName
        dayLabel.font = .systemFont(ofSize: 17)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let switchControl = UISwitch()
        switchControl.isOn = selectedDays.contains(weekday)
        switchControl.tag = indexPath.row
        switchControl.onTintColor = .ypBlue
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(dayLabel)
        cell.contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
