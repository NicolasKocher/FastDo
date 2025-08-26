import Foundation
import SwiftUI

@MainActor
class TodoStore: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var categories: [Category] = []
    @Published var selectedCategoryId: UUID?
    
    private let userDefaults = UserDefaults.standard
    private let todosKey = "MenuTodos_SavedTodos"
    private let categoriesKey = "MenuTodos_SavedCategories"
    private let selectedCategoryKey = "MenuTodos_SelectedCategory"
    
    init() {
        loadCategories()
        loadTodos()
        migrateOldTodos()
    }
    
    // MARK: - Todo Management
    func addTodo(_ text: String, categoryId: UUID? = nil) {
        let parsed = NaturalLanguageParser.parseTask(from: text)
        let targetCategoryId = categoryId ?? selectedCategoryId ?? categories.first?.id ?? UUID()
        let todo = Todo(title: parsed.title, dueDate: parsed.dueDate, categoryId: targetCategoryId)
        todos.append(todo)
        saveTodos()
    }
    
    func toggleTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveTodos()
        }
    }
    
    func updateTodo(_ todo: Todo, title: String) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            let parsed = NaturalLanguageParser.parseTask(from: title)
            todos[index].title = parsed.title
            todos[index].dueDate = parsed.dueDate
            saveTodos()
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }
    
    func reorderTodos(from source: IndexSet, to destination: Int) {
        var filteredTodos = todosForSelectedCategory
        filteredTodos.move(fromOffsets: source, toOffset: destination)
        
        // Update the original todos array
        let categoryId = selectedCategoryId ?? categories.first?.id ?? UUID()
        todos.removeAll { $0.categoryId == categoryId }
        todos.append(contentsOf: filteredTodos)
        saveTodos()
    }
    
    func clearCompleted() {
        if let categoryId = selectedCategoryId {
            todos.removeAll { $0.isCompleted && $0.categoryId == categoryId }
        } else {
            todos.removeAll { $0.isCompleted }
        }
        saveTodos()
    }
    
    // MARK: - Category Management
    func addCategory(_ name: String, color: Color = .blue, systemIcon: String = "folder.fill") {
        let category = Category(name: name, color: color, systemIcon: systemIcon)
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(_ category: Category) {
        // Prevent deleting the last category
        guard categories.count > 1 else { return }
        
        // Move todos to first remaining category
        if let firstRemainingCategory = categories.first(where: { $0.id != category.id }) {
            for index in todos.indices {
                if todos[index].categoryId == category.id {
                    todos[index].categoryId = firstRemainingCategory.id
                }
            }
        }
        
        categories.removeAll { $0.id == category.id }
        
        if selectedCategoryId == category.id {
            selectedCategoryId = categories.first?.id
        }
        
        saveCategories()
        saveTodos()
    }
    
    func selectCategory(_ categoryId: UUID?) {
        selectedCategoryId = categoryId
        userDefaults.set(categoryId?.uuidString, forKey: selectedCategoryKey)
    }
    
    // MARK: - Computed Properties
    var todosForSelectedCategory: [Todo] {
        guard let categoryId = selectedCategoryId else {
            return todos
        }
        return todos.filter { $0.categoryId == categoryId }
    }
    
    var selectedCategory: Category? {
        guard let categoryId = selectedCategoryId else { return nil }
        return categories.first { $0.id == categoryId }
    }
    
    var hasCompletedTodos: Bool {
        todosForSelectedCategory.contains { $0.isCompleted }
    }
    
    var completedCount: Int {
        todosForSelectedCategory.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        todosForSelectedCategory.count
    }
    
    var statsText: String {
        let categoryName = selectedCategory?.name ?? "All"
        if totalCount == 0 {
            return "No tasks in \(categoryName)"
        } else {
            return "\(completedCount) of \(totalCount) tasks completed"
        }
    }
    
    // MARK: - Persistence
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            userDefaults.set(encoded, forKey: todosKey)
        }
    }
    
    private func loadTodos() {
        guard let data = userDefaults.data(forKey: todosKey),
              let decodedTodos = try? JSONDecoder().decode([Todo].self, from: data) else {
            return
        }
        todos = decodedTodos
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            userDefaults.set(encoded, forKey: categoriesKey)
        }
    }
    
    private func loadCategories() {
        if let data = userDefaults.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decodedCategories
        } else {
            // First launch - create default categories
            categories = Category.defaultCategories
            saveCategories()
        }
        
        // Load selected category
        if let savedCategoryId = userDefaults.string(forKey: selectedCategoryKey),
           let uuid = UUID(uuidString: savedCategoryId),
           categories.contains(where: { $0.id == uuid }) {
            selectedCategoryId = uuid
        } else {
            selectedCategoryId = categories.first?.id
        }
    }
    
    // MARK: - Migration
    private func migrateOldTodos() {
        // Migrate old todos without categoryId to default category
        let defaultCategoryId = categories.first?.id ?? UUID()
        var needsUpdate = false
        
        for index in todos.indices {
            if todos[index].categoryId == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                todos[index].categoryId = defaultCategoryId
                needsUpdate = true
            }
        }
        
        if needsUpdate {
            saveTodos()
        }
    }
}