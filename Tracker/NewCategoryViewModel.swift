import Foundation

final class NewCategoryViewModel {
    
    private let store: TrackerCategoryStore
    
    // MARK: - Output bindings
    var onButtonStateChanged: ((Bool) -> Void)?
    var onSaveSuccess: (() -> Void)?
    var onDuplicateDetected: (() -> Void)?
    
    // MARK: - Input
    var categoryTitle: String = "" {
        didSet {
            let trimmed = categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            onButtonStateChanged?(!trimmed.isEmpty)
        }
    }

    init(store: TrackerCategoryStore) {
        self.store = store
    }
    
    func saveCategory() {
        let trimmedTitle = categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let existing = store.categories.contains { $0.title.caseInsensitiveCompare(trimmedTitle) == .orderedSame }
        
        if existing {
            onDuplicateDetected?()
            return
        }
        
        do {
            try store.createCategory(title: trimmedTitle)
            onSaveSuccess?()
        } catch {
            print("❌ Ошибка при сохранении категории: \(error)")
        }
    }
}
