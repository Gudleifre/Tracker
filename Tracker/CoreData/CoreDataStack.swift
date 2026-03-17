import CoreData

final class CoreDataStack {
    // MARK: - Singleton
    static let shared = CoreDataStack()
    private init() {}
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                assertionFailure("CoreData error: \(error), \(error.userInfo)")
                print("CoreData failed to load: \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
