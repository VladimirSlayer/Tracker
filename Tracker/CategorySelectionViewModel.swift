import Foundation

final class CategorySelectionViewModel {

    let categoryStore: TrackerCategoryStore
    var onCategoriesChanged: (() -> Void)?

    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }

    init(store: TrackerCategoryStore) {
        self.categoryStore = store
        self.categoryStore.delegate = self
        loadCategories()
    }

    func loadCategories() {
        categories = categoryStore.categories
    }

    func addCategory(with title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        categories.append(newCategory)
        onCategoriesChanged?()
    }

    func numberOfCategories() -> Int {
        categories.count
    }

    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
}

extension CategorySelectionViewModel: TrackerCategoryStoreDelegate {
    func didUpdateContent() {
        loadCategories()
    }
}

