import CoreData
import UIKit

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

    init(context: NSManagedObjectContext) {
        self.context = context

        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()
        self.fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Failed to fetch trackers: \(error)")
        }
    }

    var trackers: [Tracker] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { Tracker(coreData: $0) }
    }
    
    func togglePin(for trackerId: UUID) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        request.fetchLimit = 1

        guard let trackerCoreData = try context.fetch(request).first else {
            print("⚠️ Tracker with id \(trackerId) not found.")
            return
        }

        trackerCoreData.isPinned.toggle()
        try context.save()
    }

}
