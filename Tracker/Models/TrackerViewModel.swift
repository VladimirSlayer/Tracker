import CoreData

final class TrackerViewModel {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func addTracker() {
        let tracker = TrackerCoreData(context: context)
        try? context.save()
    }
}
