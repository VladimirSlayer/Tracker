import UIKit

struct Tracker: Identifiable, Equatable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let type: TrackerType
    let createdDate: Date
}

enum TrackerType {
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
