import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()
    
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
    
    // TODO: - add CollectionView
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIElements()
    }
    
    // MARK: - Private Methods
    private func setupUIElements() {
        view.backgroundColor = .ypWhiteDay
        
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        
        setupPlaceholder()
        
        showPlaceholder()
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
                title: "Читать книгу",
                color: .systemGreen,
                emoji: "📚",
                schedule: [.monday, .wednesday, .friday],
                isPinned: false,
                category: "Саморазвитие"
            )
        ]
        
        categories = [
            TrackerCategory(title: "Здоровье", trackers: [mockTrackers[0]]),
            TrackerCategory(title: "Саморазвитие", trackers: [mockTrackers[1]])
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
    
    @objc private func addButtonTapped() {
        print("Добавление нового трекера")
        // TODO: позже будет переход к созданию трекера
    }
}
