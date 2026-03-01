import Foundation

final class CategoriesViewModel {
    // MARK: - Public Properties
    var onStateChanged: ((CategoriesState) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onDismissRequested: (() -> Void)?
    
    // MARK: - Private Properties
    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategoryCoreData] = []
    private var selectedCategory: String?
    
    // MARK: - Initializers
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(), selectedCategory: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
        
        categoryStore.delegate = self
        loadCategories()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        onStateChanged?(.loading)
        categories = categoryStore.categories
        
        if categories.isEmpty {
            onStateChanged?(.empty)
        } else {
            updateSelection()
        }
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        let selectedCategoryTitle = categories[index].title ?? ""
        selectedCategory = selectedCategoryTitle
        onCategorySelected?(selectedCategoryTitle)
        
        updateSelection()
    }
    
    func addCategory(title: String) {
        _ = categoryStore.addCategory(title: title)
        loadCategories()
    }
    
    func deleteCategory(at index: Int) {
        categoryStore.deleteCategory(at: index)
        loadCategories()
    }
    
    func updateCategory(at index: Int, with newTitle: String) {
        categoryStore.updateCategory(at: index, with: newTitle)
        loadCategories()
    }
    
    func doneButtonTapped() {
        onDismissRequested?()
    }
    
    // MARK: - Private Methods
    private func updateSelection() {
        let viewModels = categories.map { category in
            CategoryViewModel(
                title: category.title ?? "",
                isSelected: category.title == selectedCategory
            )
        }
        onStateChanged?(.loaded(viewModels))
    }
}

// MARK: - Extensions
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        loadCategories()
    }
}
