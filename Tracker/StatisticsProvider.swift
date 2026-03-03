import Foundation

struct TrackerStatistics {
    let completedCount: Int
    let bestPeriod: Int
    let perfectDays: Int
    let averagePerDay: Int
}

final class StatisticsProvider {
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore

    init(recordStore: TrackerRecordStore, trackerStore: TrackerStore) {
        self.recordStore = recordStore
        self.trackerStore = trackerStore
    }

    func calculateStatistics() -> TrackerStatistics {
        let records = recordStore.records
        let calendar = Calendar.current

        
        let normalizedDates = records.map { calendar.startOfDay(for: $0.date) }

        
        let recordsByDay = Dictionary(grouping: normalizedDates, by: { $0 })

        let allTrackers = trackerStore.trackers
        let totalTrackers = allTrackers.count

        
        let completedCount = records.count

        
        let bestPeriod = calculateLongestStreak(from: Set(normalizedDates))

        
        let perfectDays = recordsByDay.filter { $0.value.count == totalTrackers }.count

        // Среднее: выполнений / дней
        let averagePerDay: Int
        if recordsByDay.isEmpty {
            averagePerDay = 0
        } else {
            let average = Double(completedCount) / Double(recordsByDay.count)
            averagePerDay = Int(round(average))
        }

        return TrackerStatistics(
            completedCount: completedCount,
            bestPeriod: bestPeriod,
            perfectDays: perfectDays,
            averagePerDay: averagePerDay
        )
    }

    private func calculateLongestStreak(from dates: Set<Date>) -> Int {
        guard !dates.isEmpty else { return 0 }

        let sorted = dates.sorted()
        var maxStreak = 1
        var currentStreak = 1
        let calendar = Calendar.current

        for i in 1..<sorted.count {
            let prev = sorted[i - 1]
            let curr = sorted[i]

            if let diff = calendar.dateComponents([.day], from: prev, to: curr).day, diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return maxStreak
    }
}
