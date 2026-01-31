import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
}

final class NewTrackerViewController: UIViewController {
    weak var delegate: NewTrackerViewControllerDelegate?
    // MARK: - Private Properties
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    private let defaultCategory = "Важное"
    private var selectedSchedule: [Weekday] = []
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        view.addSubview(titleTextField)
        view.addSubview(tableView)
        view.addSubview(emojiLabel)
        view.addSubview(emojiCollectionView)
        view.addSubview(colorLabel)
        view.addSubview(colorCollectionView)
        view.addSubview(buttonsStackView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupEmojiCollection()
        setupColorCollection()
    }
    
    private func setupEmojiCollection() {
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        
        if let layout = emojiCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        
        emojiCollectionView.isScrollEnabled = false
        emojiCollectionView.allowsMultipleSelection = false
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
    }
    
    private func setupColorCollection() {
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        
        if let layout = colorCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        
        colorCollectionView.isScrollEnabled = false
        colorCollectionView.allowsMultipleSelection = false
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
    
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, ),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            buttonsStackView.topAnchor.constraint(greaterThanOrEqualTo: colorCollectionView.bottomAnchor, constant: 40),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    private func updateCollectionViewHeight() {
        [emojiCollectionView, colorCollectionView].forEach { collectionView in
            collectionView.layoutIfNeeded()
            let height = collectionView.collectionViewLayout.collectionViewContentSize.height
            collectionView.constraints
                .first { $0.firstAttribute == .height }?
                .constant = height
        }
        view.layoutIfNeeded()
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
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        
        let isReadyToCreate = hasText && hasCategory && hasSchedule && hasEmoji && hasColor
        
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

extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollectionView: emojis.count
        case colorCollectionView: colors.count
        default: 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
            case emojiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell()}
            cell.configure(with: emojis[indexPath.row])
            return cell
            
        case colorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell()}
            cell.configure(with: colors[indexPath.row])
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
           let interitemSpacing: CGFloat = 5
           let sectionInsets = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
           
           let availableWidth = collectionView.frame.width - sectionInsets.left - sectionInsets.right
           let itemWidth = (availableWidth - (interitemSpacing * (itemsPerRow - 1))) / itemsPerRow
           
           return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case emojiCollectionView:
            if let selectedIndex = selectedEmojiIndex {
                let previousIndexPath = IndexPath(item: selectedIndex, section: 0)
                collectionView.deselectItem(at: previousIndexPath, animated: false)
            }
            selectedEmojiIndex = indexPath.item
            selectedEmoji = emojis[indexPath.item]
            
        case colorCollectionView:
            if let selectedIndex = selectedColorIndex {
                let previousIndexPath = IndexPath(item: selectedIndex, section: 0)
                collectionView.deselectItem(at: previousIndexPath, animated: false)
            }
            selectedColorIndex = indexPath.item
            selectedColor = colors[indexPath.item]
            
        default:
            break
        }
        updateCreateButtonState()
    }
}
