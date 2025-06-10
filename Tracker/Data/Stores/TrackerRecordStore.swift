import CoreData
import UIKit

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>

    init(context: NSManagedObjectContext) {
        self.context = context

        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

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
            print("❌ Failed to fetch records: \(error)")
        }
    }

    var records: [TrackerRecord] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap {
            guard let id = $0.id, let trackerId = $0.tracker?.id, let date = $0.date else { return nil }
            return TrackerRecord(id: id, trackerId: trackerId, date: date)
        }
    }

    func addRecord(for trackerId: UUID, on date: Date) throws {
        let trackerFetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        guard let tracker = try context.fetch(trackerFetchRequest).first else {
            print("❌ Трекер с ID \(trackerId) не найден")
            throw TrackerStoreError.trackerNotFound
        }

        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.id = UUID()
        newRecord.date = date
        newRecord.tracker = tracker
        
        try context.save()
    }

    func removeRecord(for trackerId: UUID, on date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "tracker.id == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, startOfDay as NSDate, endOfDay as NSDate)
        
        if let recordToDelete = try context.fetch(request).first {
            context.delete(recordToDelete)
            try context.save()
        }
    }

    func isTrackerCompleted(trackerId: UUID, onDate date: Date) throws -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@ AND date >= %@ AND date < %@",
                                             trackerId as CVarArg,
                                             startOfDay as NSDate,
                                             endOfDay as NSDate)
        fetchRequest.fetchLimit = 1

        let count = try context.count(for: fetchRequest)
        return count > 0
    }

    func fetchRecords(forTrackerId trackerId: UUID) throws -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]

        let coreDataRecords = try context.fetch(fetchRequest)
        
        return coreDataRecords.compactMap { coreDataRecord in
            guard let id = coreDataRecord.id,
                  let date = coreDataRecord.date,
                  let associatedTrackerId = coreDataRecord.tracker?.id else {
                print("  ⚠️ Ошибка: TrackerRecordCoreData имеет nil поля (id, date или tracker.id). Пропускаем запись.")
                return nil
            }
            return TrackerRecord(id: id, trackerId: associatedTrackerId, date: date)
        }
    }

    enum TrackerStoreError: Error {
        case trackerNotFound
    }
}
