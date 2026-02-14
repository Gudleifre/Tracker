import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    // MARK: - Initializers
    private override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
        setupFetchedResultsController()
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    var fetchedObjects: [TrackerCoreData] {
        fetchedResultsController?.fetchedObjects ?? []
    }
    
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController?.object(at: indexPath)
    }
    
    func addTracker(title: String, emoji: String, color: UIColor, schedule: [Weekday], category: TrackerCategoryCoreData) {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.title = title
        tracker.emoji = emoji
        tracker.color = color
        tracker.schedule = schedule as NSArray
        tracker.isPinned = false
        tracker.category = category
        
        saveContext()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("Error fetch: \(error)")
        }
    }
    
    private func saveContext() {
        guard context.hasChanges else {
            return
        }
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
}

// MARK: - Extensions
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
