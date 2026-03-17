import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private Properties
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private let context = CoreDataStack.shared.context
    
    // MARK: - Initializers
    override init() {
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    var categories: [TrackerCategoryCoreData] {
        fetchedResultsController?.fetchedObjects ?? []
    }
    
    func addCategory(title: String) -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        saveContext()
        return category
    }
    
    func deleteCategory(at index: Int) {
        let categories = self.categories
        guard index < categories.count else { return }
        
        let category = categories[index]
        
        if let trackers = category.trackers as? Set<TrackerCoreData> {
            
            for tracker in trackers {
                if let records = tracker.records as? Set<TrackerRecordCoreData> {
                    records.forEach {
                        context.delete($0)
                    }
                }
                context.delete(tracker)
            }
        }
        
        context.delete(category)
        saveContext()
    }
    
    func updateCategory(at index: Int, with newTitle: String) {
        let categories = self.categories
        guard index < categories.count else { return }
        let category = categories[index]
        category.title = newTitle
        saveContext()
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        fetchedResultsController?.object(at: indexPath)
    }
    
    // MARK: - Private Methods
    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("Error fetch category: \(error)")
        }
    }
}

// MARK: - Extensions
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}

extension TrackerCategoryStore {
    func fetchOrCreateCategory(title: String) -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(request).first {
                return existing
            }
        } catch {
            print("Category search error: \(error)")
        }
        return addCategory(title: title)
    }
}
