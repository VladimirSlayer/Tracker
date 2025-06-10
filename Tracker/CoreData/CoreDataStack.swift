import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        
        persistentContainer = NSPersistentContainer(name: "TrackerModel")

        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("❌ Ошибка при загрузке хранилища: \(error), \(error.userInfo)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("❌ Ошибка при сохранении контекста: \(error), \(error.userInfo)")
            }
        }
    }
}
