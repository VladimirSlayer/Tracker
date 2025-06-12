import CoreData
import UIKit

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    weak var delegate: TrackerCategoryStoreDelegate?
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

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
            print("❌ Failed to fetch categories: \(error)")
        }
    }

    var categories: [TrackerCategory] {
            print("👉 TrackerCategoryStore: Запрошена computed property 'categories'.")
            let fetchedObjects = fetchedResultsController.fetchedObjects ?? []
            print("Количество fetchedObjects (сырых CoreData категорий из FRC): \(fetchedObjects.count)")

            return fetchedObjects.compactMap { coreDataCategory in
                print("  Обрабатывается CoreDataCategory: \(coreDataCategory.title ?? "Без названия")")
                let trackerSet = coreDataCategory.trackers as? Set<TrackerCoreData> ?? []
                print("  Количество TrackerCoreData в СЫРОЙ CoreData категории '\(coreDataCategory.title ?? "Без названия")' перед маппингом в Tracker: \(trackerSet.count)")

                let trackers = trackerSet.compactMap { coreDataTracker in
                    print("    Попытка инициализировать Tracker из TrackerCoreData (id: \(coreDataTracker.id?.uuidString ?? "N/A"), name: \(coreDataTracker.name ?? "N/A"))...")
                    return Tracker(coreData: coreDataTracker)
                }
                print("  Количество успешно сконвертированных Tracker в КАТЕГОРИИ '\(coreDataCategory.title ?? "Без названия")' после compactMap: \(trackers.count)")

                return TrackerCategory(title: coreDataCategory.title ?? "", trackers: trackers)
            }
    }
    
    func createCategory(title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
    }
    
    func createTracker(_ tracker: Tracker, inCategoryTitled categoryTitle: String) throws {
        let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        let existingCategories = try context.fetch(categoryFetchRequest)
        let category: TrackerCategoryCoreData
        
        if let existingCategory = existingCategories.first {
            category = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = categoryTitle
            category = newCategory
        }

        let newTrackerCoreData = TrackerCoreData(context: context)
        newTrackerCoreData.id = tracker.id
        newTrackerCoreData.name = tracker.name
        newTrackerCoreData.color = tracker.color
        newTrackerCoreData.emoji = tracker.emoji
        newTrackerCoreData.schedule = tracker.schedule.map(\.rawValue) as NSArray
        newTrackerCoreData.type = tracker.type.rawValue
        newTrackerCoreData.createdDate = tracker.createdDate
        
        category.addToTrackers(newTrackerCoreData)
        
        try context.save()
        
        do {
                try context.save()
                print("✅ Трекер '\(tracker.name)' успешно сохранен в категории '\(categoryTitle)'")

                print("--- Сохраненный TrackerCoreData ---")
                print("ID: \(newTrackerCoreData.id?.uuidString ?? "N/A")")
                print("Name: \(newTrackerCoreData.name ?? "N/A")")

                if let savedColor = newTrackerCoreData.color {
                    print("Color (as stored): \(savedColor)")
                } else {
                    print("Color: N/A or nil")
                }


                if let savedSchedule = newTrackerCoreData.schedule {
                    print("Schedule (as stored): \(savedSchedule)")
                    if let scheduleData = savedSchedule as? Data {
                        if let decodedSchedule = try? JSONDecoder().decode([Weekday].self, from: scheduleData) {
                            print("Decoded Schedule (from stored Data): \(decodedSchedule.map { $0.rawValue })")
                        } else {
                            print("Failed to decode schedule from Data.")
                        }
                    } else if let scheduleArray = savedSchedule as? [String] {
                         print("Schedule (as stored array): \(scheduleArray)")
                    }
                } else {
                    print("Schedule: N/A or nil")
                }
            print("  Количество трекеров в CoreData-категории '\(category.title ?? "Без названия")' сразу после сохранения: \(category.trackers?.count ?? 0)")
                print("-----------------------------------")


            } catch {
                print("❌ Не удалось создать трекер (ошибка сохранения): \(error)")
                throw error
            }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            print("🔄 NSFetchedResultsControllerDelegate: Данные изменились. Уведомляем делегата.")
            delegate?.didUpdateContent()
        }
}
