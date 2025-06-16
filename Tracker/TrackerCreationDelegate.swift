protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
    func didEditTracker(_ tracker: Tracker, newCategory: TrackerCategory)
}
