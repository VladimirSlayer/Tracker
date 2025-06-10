import UIKit
import CoreData

struct Tracker: Identifiable, Equatable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let type: TrackerType
    let createdDate: Date
}

enum TrackerType: String, Codable {
    case habit
    case event
}

enum Weekday: String, CaseIterable, Codable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
}

extension Weekday {
    var index: Int {
        switch self {
        case .sunday: return 0
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        }
    }
}

extension Tracker {
    init?(coreData: TrackerCoreData) {
        print("\n--- Начало инициализатора Tracker (для: \(coreData.name ?? "N/A")) ---")

        guard
            let id = coreData.id
        else {
            print("  ⚠️ Ошибка: 'id' отсутствует. Возвращаем nil.")
            return nil
        }
        print("  ✅ ID: \(id.uuidString)")

        guard
            let name = coreData.name
        else {
            print("  ⚠️ Ошибка: 'name' отсутствует для ID: \(id.uuidString). Возвращаем nil.")
            return nil
        }
        print("  ✅ Name: \(name)")

        guard
            let emoji = coreData.emoji
        else {
            print("  ⚠️ Ошибка: 'emoji' отсутствует для '\(name)'. Возвращаем nil.")
            return nil
        }
        print("  ✅ Emoji: \(emoji)")

        guard
            let typeStr = coreData.type
        else {
            print("  ⚠️ Ошибка: 'type' (строка) отсутствует для '\(name)'. Возвращаем nil.")
            return nil
        }
        print("  ✅ Type string: \(typeStr)")

        guard
            let type = TrackerType(rawValue: typeStr)
        else {
            print("  ⚠️ Ошибка: Не удалось инициализировать TrackerType из '\(typeStr)' для '\(name)'. Возвращаем nil.")
            return nil
        }
        print("  ✅ Type (enum): \(type.rawValue)")

        guard
            let createdDate = coreData.createdDate
        else {
            print("  ⚠️ Ошибка: 'createdDate' отсутствует для '\(name)'. Возвращаем nil.")
            return nil
        }
        print("  ✅ Created Date: \(createdDate)")

        print("  Попытка декодировать цвет...")
        let color: UIColor
        if let storedColor = coreData.color as? UIColor {
            color = storedColor
            print("  ✅ Цвет успешно прочитан как UIColor (Transformable с Custom Class).")
        } else if let colorData = coreData.color as? Data {
            if let decodedColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                color = decodedColor
                print("  ✅ Цвет успешно декодирован из Data (NSKeyedUnarchiver).")
            } else {
                print("  ⚠️ Ошибка: Не удалось декодировать цвет из Data для '\(name)'. Размер Data: \(colorData.count) bytes. Возвращаем nil.")
                return nil
            }
        } else if coreData.color == nil {
            print("  ⚠️ Ошибка: CoreData.color nil для '\(name)'. Возвращаем nil.")
            return nil
        } else {
            let colorValueDescription = String(describing: coreData.color)
            print("  ⚠️ Ошибка: CoreData.color имеет неожиданный тип для '\(name)'. Значение: \(colorValueDescription). Возвращаем nil.")
            return nil
        }


        print("  Попытка декодировать расписание...")
        let schedule: [Weekday]
        if let storedSchedule = coreData.schedule as? [Weekday] {
            schedule = storedSchedule
            print("  ✅ Расписание успешно прочитано как [Weekday] (Transformable с Custom Class): \(storedSchedule.map { $0.rawValue }).")
        } else if let scheduleData = coreData.schedule as? Data {
            if let decodedSchedule = try? JSONDecoder().decode([Weekday].self, from: scheduleData) {
                schedule = decodedSchedule
                print("  ✅ Расписание успешно декодировано из Data (JSONDecoder): \(decodedSchedule.map { $0.rawValue }).")
            } else {
                print("  ⚠️ Ошибка: Не удалось декодировать расписание из Data для '\(name)'. Размер Data: \(scheduleData.count) bytes. Возвращаем nil.")
                return nil
            }
        } else if let rawSchedule = coreData.schedule as? [String] {
             schedule = rawSchedule.compactMap(Weekday.init(rawValue:))
             print("  ✅ Расписание успешно маплено из [String]: \(schedule.map { $0 }).")
        } else if coreData.schedule == nil {
            print("  ⚠️ Ошибка: CoreData.schedule nil для '\(name)'. Возвращаем nil.")
            return nil
        } else {
            let scheduleValueDescription = String(describing: coreData.schedule)
            print("  ⚠️ Ошибка: CoreData.schedule имеет неожиданный тип для '\(name)'. Значение: \(scheduleValueDescription). Возвращаем nil.")
            return nil
        }

        print("--- Инициализатор Tracker успешно завершен для: '\(name)' ---")
        self.init(id: id, name: name, color: color, emoji: emoji, schedule: schedule, type: type, createdDate: createdDate)
    }
}

