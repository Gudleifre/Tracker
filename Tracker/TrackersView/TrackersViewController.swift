import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
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
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        return searchController
    }()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var categories: [TrackerCategory] {
        return categoriesForUI
    }
    
    private var allTrackers: [TrackerCoreData] {
        trackerStore.fetchedObjects
    }
    
    private var allRecords: [TrackerRecordCoreData] {
        recordStore.records
    }
    
    private var filteredTrackers: [TrackerCoreData] {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: currentDate)
        guard let currentWeekday = Weekday.from(weekdayNumber) else { return [] }
        
        return allTrackers.filter { tracker in
            guard let schedule = tracker.schedule as? [Weekday] else { return false }
            return schedule.contains(currentWeekday) || schedule.isEmpty
        }
    }
    
    private var categoriesForUI: [TrackerCategory] {
        let grouped = Dictionary(grouping: filteredTrackers) { tracker in
            tracker.category?.title ?? "Без категории"
        }
        return grouped.map { categoryTitle, trackers in
            let trackerStructs = trackers.map { tracker in
                Tracker(
                    id: tracker.id ?? UUID(),
                    title: tracker.title ?? "",
                    color: tracker.color as? UIColor ?? .systemBlue,
                    emoji: tracker.emoji ?? "",
                    schedule: (tracker.schedule as? [Weekday]) ?? [],
                    isPinned: tracker.isPinned,
                    category: categoryTitle
                )
            }
            return TrackerCategory(title: categoryTitle, trackers: trackerStructs)
        }.sorted { $0.title < $1.title }
    }
    
    // MARK: - Initializers
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
        
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePlaceholderVisibility()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupSearchBarAppearance()
    }
    
    // MARK: - Public Methods
    func updateUI() {
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        setupPlaceholder()
        setupDatePicker()
        setupTrackersCollection()
    }
    
    private func setupSearchBarAppearance() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        for subview in navigationBar.subviews {
            for subSubview in subview.subviews {
                if let searchBar = subSubview as? UISearchBar {
                    searchBar.frame.size.height = 44
                    
                    if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                        textField.frame.size.height = 36
                        textField.center.y = searchBar.bounds.midY
                        textField.backgroundColor = .ypSearchPlaceholder
                        textField.layer.cornerRadius = 10
                        textField.clipsToBounds = true
                        textField.font = .systemFont(ofSize: 17, weight: .regular)
                    }
                    
                    return
                }
            }
        }
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
            
            placeholderView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            placeholderView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupTrackersCollection() {
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
    
    private func completeTracker(id: UUID, date: Date) {
        guard let tracker = allTrackers.first(where: { $0.id == id }) else { return }
        _ = recordStore.addRecord(tracker: tracker, date: date)
    }
    
    private func uncompleteTracker(id: UUID, date: Date) {
        guard allTrackers.first(where: { $0.id == id }) != nil else { return }
        
        if let record = allRecords.first(where: {
            $0.tracker?.id == id &&
            Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date)
        }) {
            recordStore.deleteRecord(record)
        }
    }
    
    private func isTrackerCompleted(id: UUID, on date: Date) -> Bool {
        return allRecords.contains { record in
            record.tracker?.id == id &&
            Calendar.current.isDate(record.date ?? Date(), inSameDayAs: date)
        }
    }
    
    private func completedDaysCount(for trackerId: UUID) -> Int {
        return allRecords.filter { $0.tracker?.id == trackerId }.count
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
        let totalTrackers = filteredTrackers.count
        
        if totalTrackers == 0 {
            showPlaceholder()
        } else {
            hidePlaceholder()
        }
    }
    
    // MARK: - @objc Methods
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.dateOnly
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        let newTrackerVC = NewTrackerViewController()
        let navController = UINavigationController(rootViewController: newTrackerVC)
        
        newTrackerVC.delegate = self
        present(navController, animated: true)
    }
    
    @objc private func plusButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        let section = tag / 100
        let row = tag % 100
        
        guard section < categories.count else { return }
        guard row < categories[section].trackers.count else { return }
        
        let tracker = categories[section].trackers[row]
        
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
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersViewCell.identifier, for: indexPath) as? TrackersViewCell else { return UICollectionViewCell() }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let isCompleted = isTrackerCompleted(id: tracker.id, on: currentDate)
        let completedDays = completedDaysCount(for: tracker.id)
        
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
        header.configure(withTitle: category.title)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 16 * 3) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return categories[section].trackers.isEmpty ? .zero : CGSize(width: collectionView.bounds.width, height: 33)
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

extension TrackersViewController: NewTrackerViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        let categoryCoreData = categoryStore.fetchOrCreateCategory(title: category)
        trackerStore.addTracker(
            title: tracker.title,
            emoji: tracker.emoji,
            color: tracker.color,
            schedule: tracker.schedule,
            category: categoryCoreData
        )
        
        dismiss(animated: true)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}
