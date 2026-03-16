import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    private var visibleCategories: [TrackerCategory] = []
    private var isSearching: Bool = false
    private var searchText: String = ""
    
    private var currentFilter: TrackerFilter = .all
    private let filterStorage = UserDefaults.standard
    private let filterKey = "selected_filter"
    
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
        searchController.searchBar.placeholder = NSLocalizedString(
            "search_placeholder", comment: "Search placeholder"
        )
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters_button", comment: "Filters button"), for: .normal)
        button.setTitleColor(.ypWhiteStatic, for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
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
            tracker.category?.title ?? ""
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
        visibleCategories = categories
        updatePlaceholderVisibility()
        loadSavedFilter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.reportEvent(screen: "Main", event: "open")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.reportEvent(screen: "Main", event: "close")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupSearchBarAppearance()
    }
    
    // MARK: - Public Methods
    func updateUI() {
        filterTrackers()
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
        updateFilterButtonVisibility()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        
        title = NSLocalizedString("trackers_title", comment: "Trackers screen title")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = true
        
        navigationItem.leftBarButtonItem = addButton
        navigationItem.searchController = searchController
        
        setupDatePicker()
        setupTrackersCollection()
        setupFilterButton()
        setupPlaceholder()
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
        placeholderView.addSubview(placeholderImageView)
        placeholderView.addSubview(placeholderLabel)
        view.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor, constant: -20),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            
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
        trackersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        trackersCollectionView.scrollIndicatorInsets = trackersCollectionView.contentInset
        
        view.addSubview(trackersCollectionView)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.bringSubviewToFront(filterButton)
    }
    
    private func updateFilterButtonVisibility() {
        let hasTrackers = !filteredTrackers.isEmpty
        filterButton.isHidden = !hasTrackers
    }
    
    private func showAppropriatePlaceholder() {
        if isSearching && !searchText.isEmpty {
            showNoResultsPlaceholder()
        } else if currentFilter == .completed || currentFilter == .uncompleted {
            showNoResultsPlaceholder()
        } else {
            showEmptyPlaceholder()
        }
    }
    
    private func showEmptyPlaceholder() {
        placeholderImageView.image = UIImage(resource: .placeholderForTrackers)
        placeholderLabel.text = NSLocalizedString("what_to_track", comment: "trackers placeholder label")
        placeholderView.isHidden = false
        filterButton.isHidden = true
    }
    
    private func showNoResultsPlaceholder() {
        placeholderImageView.image = UIImage(resource: .searchPlaceholder)
        placeholderLabel.text = NSLocalizedString("nothing_found", comment: "search placeholder label")
        placeholderView.isHidden = false
        filterButton.isHidden = true
    }
    
    private func hidePlaceholder() {
        placeholderView.isHidden = true
        filterButton.isHidden = false
    }
    
    private func updatePlaceholderVisibility() {
        let hasTrackers = !visibleCategories.flatMap { $0.trackers }.isEmpty
        if hasTrackers {
            hidePlaceholder()
        } else {
            filterButton.isHidden = true
            
            if isSearching {
                showNoResultsPlaceholder()
            } else if currentFilter == .completed || currentFilter == .uncompleted {
                showNoResultsPlaceholder()
            } else {
                showEmptyPlaceholder()
            }
        }
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
        allRecords.contains { record in
            record.tracker?.id == id &&
            Calendar.current.isDate(record.date ?? Date(), inSameDayAs: date)
        }
    }
    
    private func completedDaysCount(for trackerId: UUID) -> Int {
        allRecords.filter { $0.tracker?.id == trackerId }.count
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: Locale.current.identifier)
        datePicker.maximumDate = Date()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    private func filterTrackers() {
        isSearching = !(searchController.searchBar.text?.isEmpty ?? true)
        
        var filteredByDate = filteredTrackers
        
        switch currentFilter {
        case .all, .today:
            break
        case .completed:
            filteredByDate = filteredByDate.filter { tracker in
                isTrackerCompleted(id: tracker.id ?? UUID(), on: currentDate)
            }
        case .uncompleted:
            filteredByDate = filteredByDate.filter { tracker in
                !isTrackerCompleted(id: tracker.id ?? UUID(), on: currentDate)
            }
        }
        
        let grouped = Dictionary(grouping: filteredByDate) { tracker in
            tracker.category?.title ?? ""
        }
        
        var filteredCategories = grouped.map { title, trackers in
            TrackerCategory(
                title: title,
                trackers: trackers.map { tracker in
                    Tracker(
                        id: tracker.id ?? UUID(),
                        title: tracker.title ?? "",
                        color: tracker.color as? UIColor ?? .systemBlue,
                        emoji: tracker.emoji ?? "",
                        schedule: (tracker.schedule as? [Weekday]) ?? [],
                        isPinned: tracker.isPinned,
                        category: title
                    )
                }
            )
        }.sorted { $0.title < $1.title }
        
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            filteredCategories = filteredCategories.compactMap { category in
                let filtered = category.trackers.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
                return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
            }
        }
        
        visibleCategories = filteredCategories
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func loadSavedFilter() {
        let savedValue = filterStorage.integer(forKey: filterKey)
        currentFilter = TrackerFilter(rawValue: savedValue) ?? .all
    }
    
    
    // MARK: - @objc Methods
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.dateOnly
        filterTrackers()
    }
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        AnalyticsService.reportClick(screen: "Main", item: "add_track")
        let newTrackerVC = NewTrackerViewController()
        let navController = UINavigationController(rootViewController: newTrackerVC)
        
        newTrackerVC.delegate = self
        present(navController, animated: true)
    }
    
    @objc private func plusButtonTapped(_ sender: UIButton) {
        AnalyticsService.reportClick(screen: "Main", item: "track")
        let tag = sender.tag
        let section = tag / 100
        let row = tag % 100
        
        guard section < visibleCategories.count,
              row < visibleCategories[section].trackers.count else { return }
        
        let tracker = visibleCategories[section].trackers[row]
        
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
    
    @objc private func filterButtonTapped() {
        AnalyticsService.reportClick(screen: "Main", item: "filter")
        let filterVC = FiltersViewController(selectedFilter: currentFilter)
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
}

// MARK: - Extensions
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersViewCell.identifier, for: indexPath) as? TrackersViewCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
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
        
        let category = visibleCategories[indexPath.section]
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
        return visibleCategories[section].trackers.isEmpty ? .zero : CGSize(width: collectionView.bounds.width, height: 33)
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
    
    func didUpdateTracker(_ tracker: Tracker, category: String) {
        guard let trackerToUpdate = allTrackers.first(where: { $0.id == tracker.id }) else { return }
        
        trackerToUpdate.title = tracker.title
        trackerToUpdate.emoji = tracker.emoji
        trackerToUpdate.color = tracker.color
        trackerToUpdate.schedule = tracker.schedule as NSObject
        trackerToUpdate.category = categoryStore.fetchOrCreateCategory(title: category)
        
        trackerStore.saveContext()
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

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        filterTrackers()
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersViewCell else {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let previewController = UIViewController()
            previewController.view.addSubview(cell.createPreview(with: tracker))
            previewController.preferredContentSize = CGSize(width: 167, height: 90)
            return previewController
        }) { [weak self] _ in
            
            let editAction = UIAction(
                title: NSLocalizedString("edit_action", comment: "Edit"),
                image: nil
            ) { _ in
                self?.editTracker(tracker)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("delete_action", comment: "Delete"),
                image: nil,
                attributes: .destructive
            ) { [weak self] _ in
                self?.showDeleteConfirmation(for: tracker)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

extension TrackersViewController {
    private func editTracker(_ tracker: Tracker) {
        AnalyticsService.reportClick(screen: "Main", item: "edit")
        let editVC = NewTrackerViewController()
        editVC.mode = .edit
        editVC.trackerToEdit = tracker
        editVC.delegate = self
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
        
    }
    
    private func showDeleteConfirmation(for tracker: Tracker) {
        AnalyticsService.reportClick(screen: "Main", item: "delete")
        let alert = UIAlertController(
            title: NSLocalizedString("delete_tracker_title", comment: "Delete tracker"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete_action", comment: "Delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel_action", comment: "Cancel"),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        
        guard let trackerToDelete = allTrackers.first(where: { $0.id == tracker.id }) else {
            return
        }
        trackerStore.deleteTracker(trackerToDelete)
    }
    
    private func saveFilter() {
        filterStorage.set(currentFilter.rawValue, forKey: filterKey)
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        saveFilter()
        
        switch filter {
        case .all:
            applyFilter()
            
        case .today:
            if let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker {
                datePicker.date = Date()
                datePicker.sendActions(for: .valueChanged)
            }
            applyFilter()
            
        case .completed, .uncompleted:
            applyFilter()
        }
        
        updateFilterButtonAppearance()
    }
    
    private func applyFilter() {
        filterTrackers()
        updatePlaceholderVisibility()
        updateFilterButtonAppearance()
    }
    
    private func updateFilterButtonAppearance() {
        switch currentFilter {
        case .all, .today:
            filterButton.backgroundColor = .ypBlue
            filterButton.setTitleColor(.ypWhiteStatic, for: .normal)
        case .completed, .uncompleted:
            filterButton.backgroundColor = .ypRed
            filterButton.setTitleColor(.ypWhiteStatic, for: .normal)
        }
    }
}
