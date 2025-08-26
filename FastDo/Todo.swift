import Foundation

struct Todo: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    var dueDate: Date?
    var categoryId: UUID
    
    init(title: String, isCompleted: Bool = false, dueDate: Date? = nil, categoryId: UUID) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.dueDate = dueDate
        self.categoryId = categoryId
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, createdAt, dueDate, categoryId
    }
}