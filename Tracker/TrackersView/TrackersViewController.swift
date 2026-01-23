import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()
    private var trackersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(resource: .plus),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        button.tintColor = .ypBlackDay
        return button
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
        setupUIElements()
        setupCollectionView()
        loadMockData()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Private Methods
    private func setupUIElements() {
        view.backgroundColor = .ypWhiteDay
        
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        
        setupPlaceholder()
        setupDatePicker()
    }
    
    private func setupPlaceholder() {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .placeholderForTrackers)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderView.addSubview(imageView)
        placeholderView.addSubview(label)
        view.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor, constant: -20),
            
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            placeholderView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupCollectionView() {
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        trackersCollectionView.register(TrackersViewCell.self, forCellWithReuseIdentifier: TrackersViewCell.identifier)
        trackersCollectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        
        if let layout = trackersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        trackersCollectionView.backgroundColor = .clear
        
        view.addSubview(trackersCollectionView)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func showPlaceholder() {
        placeholderView.isHidden = false
    }
    
    private func hidePlaceholder() {
        placeholderView.isHidden = true
    }
    
    private func loadMockData() {
        let mockTrackers = [
            Tracker(
                id: UUID(),
                title: "Пить воду",
                color: .systemBlue,
                emoji: "💧",
                schedule: [.monday, .tuesday, .wednesday, .thursday, .friday],
                isPinned: false,
                category: "Здоровье"
            ),
            Tracker(
                id: UUID(),
                title: "Поливать растения",
                color: .systemGreen,
                emoji: "😪",
                schedule: [.monday, .wednesday, .friday],
                isPinned: false,
                category: "Домашний уют"
            )
        ]
        
        categories = [
            TrackerCategory(title: "Здоровье", trackers: [mockTrackers[0]]),
            TrackerCategory(title: "Домашний уют", trackers: [mockTrackers[1]])
        ]
        
        completedTrackers = []
    }
    
    private func completeTracker(id: UUID, date: Date) {
        let record = TrackerRecord(id: id, date: date)
        completedTrackers.append(record)
    }
    
    private func uncompleteTracker(id: UUID, date: Date) {
        completedTrackers.removeAll { record in
            record.id == id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func isTrackerCompleted(id: UUID, on date: Date) -> Bool {
        return completedTrackers.contains { record in
            record.id == id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func addNewTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        if let index = categories.firstIndex(where: {$0.title == categoryTitle}) {
            let oldCategory = categories[index]
            let newTrackers = oldCategory.trackers + [tracker]
            let newCategory = TrackerCategory(title: oldCategory.title, trackers: newTrackers)
            
            var newCategories = categories
            newCategories[index] = newCategory
            categories = newCategories
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
    }
    
    private func trackersForCurrentDate() -> [Tracker] {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: currentDate)
        guard let currentWeekday = Weekday.from(weekdayNumber) else { return [] }
        
        return categories.flatMap { category in
            category.trackers.filter { tracker in
                tracker.schedule.contains(currentWeekday) || tracker.schedule.isEmpty
            }
        }
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.maximumDate = Date()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    private func updatePlaceholderVisibility() {
        let totalTrackers = trackersForCurrentDate().count
        
        if totalTrackers == 0 {
            showPlaceholder()
        } else {
            hidePlaceholder()
        }
    }
    
    // MARK: - @objc Methods
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: sender.date)
        print("Выбранная дата: \(formattedDate)")
    }
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        print("Добавление нового трекера")
        // TODO: - доделать реализацию добавления трекера
    }
    
    @objc private func plusButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        let section = tag / 100
        let row = tag % 100
        
        guard section < categories.count else { return }
        
        let category = categories[section]
        let trackers = trackersForCurrentDate()
        let categoryTrackers = trackers.filter { $0.category == category.title }
        
        guard row < categories.count else { return }
        
        let tracker = categoryTrackers[row]
        
        if currentDate > Date() {
            return
        }
        
        if isTrackerCompleted(id: tracker.id, on: currentDate){
            uncompleteTracker(id: tracker.id, date: currentDate)
        } else {
            completeTracker(id: tracker.id, date: currentDate)
        }
        
        let indexPath = IndexPath(row: row, section: section)
        trackersCollectionView.reloadItems(at: [indexPath])
    }
}
// MARK: - Extensions
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = categories[section]
        let trackers = trackersForCurrentDate()
        
        let categoryTrackers = trackers.filter { $0.category == category.title }
        return categoryTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersViewCell.identifier, for: indexPath) as? TrackersViewCell else { return UICollectionViewCell() }
        
        let category = categories[indexPath.section]
        let trackers = trackersForCurrentDate()
        let categoryTrackers = trackers.filter { $0.category == category.title }
        
        guard indexPath.row < categoryTrackers.count else { return cell }
        
        let tracker = categoryTrackers[indexPath.row]
        let isCompleted = isTrackerCompleted(id: tracker.id, on: currentDate)
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays)
        cell.plusButton.tag = (indexPath.section * 100) + indexPath.row
        cell.plusButton.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryHeaderView.identifier,
                for: indexPath
              ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        let category = categories[indexPath.section]
        let trackers = trackersForCurrentDate()
        let categoryTrackers = trackers.filter { $0.category == category.title }
        
        if categoryTrackers.count > 0 {
            header.configure(withTitle: category.title)
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 16 * 3) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let category = categories[section]
        let trackers = trackersForCurrentDate()
        let categoryTrackers = trackers.filter { $0.category == category.title }
        
        return categoryTrackers.count > 0 ? CGSize(width: collectionView.bounds.width, height: 33) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}
