import SwiftUI

struct CategoryColor: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    let name: String
    
    static func == (lhs: CategoryColor, rhs: CategoryColor) -> Bool {
        lhs.id == rhs.id
    }
}

struct CategoryView: View {
    @EnvironmentObject var todoStore: TodoStore
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var selectedColorId = UUID()
    @State private var selectedIcon = "folder.fill"
    
    private let availableIcons = [
        "folder.fill", "briefcase.fill", "cart.fill", "heart.fill",
        "star.fill", "house.fill", "car.fill", "gamecontroller.fill",
        "book.fill", "music.note", "camera.fill", "phone.fill"
    ]
    
    private let availableColors: [CategoryColor] = [
        CategoryColor(color: .blue, name: "blue"),
        CategoryColor(color: .green, name: "green"),
        CategoryColor(color: .orange, name: "orange"),
        CategoryColor(color: .red, name: "red"),
        CategoryColor(color: .purple, name: "purple"),
        CategoryColor(color: .pink, name: "pink"),
        CategoryColor(color: .yellow, name: "yellow"),
        CategoryColor(color: .cyan, name: "cyan"),
        CategoryColor(color: .mint, name: "mint"),
        CategoryColor(color: .indigo, name: "indigo"),
        CategoryColor(color: .brown, name: "brown"),
        CategoryColor(color: .gray, name: "gray")
    ]
    
    private var selectedColor: Color {
        availableColors.first { $0.id == selectedColorId }?.color ?? .blue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Categories")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.borderless)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Categories List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(todoStore.categories) { category in
                        CategoryRowView(
                            category: category,
                            isSelected: todoStore.selectedCategoryId == category.id,
                            todoCount: todoStore.todos.filter { $0.categoryId == category.id }.count,
                            onSelect: { todoStore.selectCategory(category.id) },
                            onDelete: { todoStore.deleteCategory(category) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(width: 300, height: 400)
        .background(Color(NSColor.textBackgroundColor))
        .sheet(isPresented: $showingAddCategory, onDismiss: {}) {
            AddCategorySheet(
                categoryName: $newCategoryName,
                selectedColorId: $selectedColorId,
                selectedIcon: $selectedIcon,
                availableColors: availableColors,
                availableIcons: availableIcons,
                onSave: {
                    todoStore.addCategory(newCategoryName, color: selectedColor, systemIcon: selectedIcon)
                    newCategoryName = ""
                    if let firstColor = availableColors.first {
                        selectedColorId = firstColor.id
                    }
                    selectedIcon = "folder.fill"
                    showingAddCategory = false
                }
            )
            .interactiveDismissDisabled(false)
        }
        .onAppear {
            // Set initial color selection
            if let firstColor = availableColors.first {
                selectedColorId = firstColor.id
            }
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    let isSelected: Bool
    let todoCount: Int
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: category.systemIcon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(category.swiftUIColor)
                .frame(width: 24, height: 24)
            
            // Name and count
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("\(todoCount) tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete button (only for non-default categories)
            if !category.isDefault {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(0.7)
                .help("Delete category")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? category.swiftUIColor.opacity(0.15) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? category.swiftUIColor : Color.clear, lineWidth: 2)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct AddCategorySheet: View {
    @Binding var categoryName: String
    @Binding var selectedColorId: UUID
    @Binding var selectedIcon: String
    let availableColors: [CategoryColor]
    let availableIcons: [String]
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var selectedColor: Color {
        availableColors.first { $0.id == selectedColorId }?.color ?? .blue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Text("New Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Category Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("Enter category name", text: $categoryName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Icon Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(selectedIcon == icon ? .white : selectedColor)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(selectedIcon == icon ? selectedColor : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(selectedColor, lineWidth: selectedIcon == icon ? 0 : 1.5)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableColors) { categoryColor in
                                Button {
                                    selectedColorId = categoryColor.id
                                } label: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(categoryColor.color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.primary, lineWidth: selectedColorId == categoryColor.id ? 3 : 0)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .opacity(selectedColorId == categoryColor.id ? 1 : 0)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedColor)
                            
                            Text(categoryName.isEmpty ? "Category Name" : categoryName)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(categoryName.isEmpty ? .secondary : .primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedColor, lineWidth: 1.5)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .frame(width: 450, height: 500)
        .background(Color(NSColor.textBackgroundColor))
    }
}

#Preview {
    CategoryView()
        .environmentObject(TodoStore())
}