import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    static let shared = TrackerRecordStore()
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
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
    var records: [TrackerRecordCoreData] {
        fetchedResultsController?.fetchedObjects ?? []
    }
    
    func addRecord(tracker: TrackerCoreData, date: Date) -> TrackerRecordCoreData {
        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.date = date
        record.tracker = tracker
        saveContext()
        return record
    }
    
    func deleteRecord(_ record: TrackerRecordCoreData) {
        context.delete(record)
        saveContext()
    }
    
    func fetchRecords(for tracker: TrackerCoreData) -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "tracker == %@", tracker)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching records for tracker: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("Error fetch records: \(error)")
        }
    }
    
    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Error saving record: \(error)")
        }
    }
}

// MARK: - Extensions
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
