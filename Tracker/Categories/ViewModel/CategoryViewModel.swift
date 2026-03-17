import Foundation

struct CategoryViewModel {
    let title: String
    let isSelected: Bool
}

enum CategoriesState {
    case loading
    case loaded([CategoryViewModel])
    case empty
    case error(String)
}
