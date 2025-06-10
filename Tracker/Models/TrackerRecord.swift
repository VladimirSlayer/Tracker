import UIKit

struct TrackerRecord: Identifiable, Equatable {
    let id: UUID
    let trackerId: UUID
    let date: Date
}
