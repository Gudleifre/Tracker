import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
}

final class NewTrackerViewController: UIViewController {
    weak var delegate: NewTrackerViewControllerDelegate?
    // MARK: - Private Properties
    private let defaultCategory = "Важное"
    private var selectedSchedule: [Weekday] = []
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackgroundDay
        textField.layer.cornerRadius = 16
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.returnKeyType = .done
        textField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        hideKeyboardWhenTappedAround()
        
        if let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            categoryCell.detailTextLabel?.text = defaultCategory
            categoryCell.detailTextLabel?.textColor = .ypGray
        }
        
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        
        title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.ypBlackDay
        ]
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(titleTextField)
        view.addSubview(tableView)
        view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    private func setupActions() {
        titleTextField.addAction(UIAction { [weak self] _ in self?.textFieldDidChange() }, for: .editingChanged)
        
        cancelButton.addAction(UIAction { [weak self] _ in self?.cancelButtonTapped() }, for: .touchUpInside)
        createButton.addAction(UIAction { [weak self] _ in self?.createButtonTapped() }, for: .touchUpInside)
    }
    
    private func updateCreateButtonState() {
        let hasText = !(titleTextField.text?.isEmpty ?? true)
        let hasCategory = true
        let hasSchedule = !selectedSchedule.isEmpty
        
        let isReadyToCreate = hasText && hasCategory && hasSchedule
        
        createButton.isEnabled = isReadyToCreate
        createButton.backgroundColor = isReadyToCreate ? .ypBlackDay : .ypGray
    }
    
    private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func createButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              !selectedSchedule.isEmpty else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: .colorSelection1,
            emoji: "👨🏻‍💻",
            schedule: selectedSchedule,
            isPinned: false,
            category: defaultCategory)
        
        delegate?.didCreateTracker(newTracker, category: defaultCategory)
        dismiss(animated: true)
    }
}

// MARK: - Extensions
extension NewTrackerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.identifier, for: indexPath) as? OptionTableViewCell else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = defaultCategory
            
            
        } else {
            cell.textLabel?.text = "Расписание"
            if !selectedSchedule.isEmpty {
                cell.detailTextLabel?.text = selectedSchedule.map { $0.shortName }.joined(separator: ", ")
            }
        }
        return cell
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("Выбор категории")
        } else {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: [Weekday]) {
        selectedSchedule = schedule
        if let scheduleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
            if !schedule.isEmpty {
                let daysString = schedule.map { $0.shortName }.joined(separator: ", ")
                scheduleCell.detailTextLabel?.text = daysString
                scheduleCell.detailTextLabel?.textColor = .ypGray
            }
        }
        
        updateCreateButtonState()
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
