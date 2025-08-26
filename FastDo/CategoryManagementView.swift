import SwiftUI

struct CategoryManagementView: View {
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
                Text("Category Management")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    showingAddCategory = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                        Text("New Category")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if showingAddCategory {
                // Inline Add Category Form
                VStack(spacing: 20) {
                    // Category Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category Name")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Enter category name", text: $newCategoryName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Icon Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Icon")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(selectedIcon == icon ? .white : selectedColor)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedIcon == icon ? selectedColor : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(selectedColor, lineWidth: selectedIcon == icon ? 0 : 2)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Color")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableColors) { categoryColor in
                                Button {
                                    selectedColorId = categoryColor.id
                                } label: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(categoryColor.color)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white, lineWidth: selectedColorId == categoryColor.id ? 4 : 0)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                                .opacity(selectedColorId == categoryColor.id ? 1 : 0)
                                        )
                                        .shadow(color: selectedColorId == categoryColor.id ? categoryColor.color.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Preview and Action Buttons
                    VStack(spacing: 16) {
                        // Preview
                        HStack(spacing: 12) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(selectedColor)
                            
                            Text(newCategoryName.isEmpty ? "Preview Category" : newCategoryName)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(newCategoryName.isEmpty ? .secondary : .primary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedColor.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedColor, lineWidth: 2)
                                )
                        )
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                cancelAddCategory()
                            }
                            .buttonStyle(.borderless)
                            
                            Spacer()
                            
                            Button("Save Category") {
                                saveCategory()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color(NSColor.textBackgroundColor))
                
                Divider()
            }
            
            // Categories List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(todoStore.categories) { category in
                        CategoryManagementRowView(
                            category: category,
                            todoCount: todoStore.todos.filter { $0.categoryId == category.id }.count,
                            onDelete: { todoStore.deleteCategory(category) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .onAppear {
            // Set initial color selection
            if let firstColor = availableColors.first {
                selectedColorId = firstColor.id
            }
        }
    }
    
    private func saveCategory() {
        todoStore.addCategory(newCategoryName, color: selectedColor, systemIcon: selectedIcon)
        cancelAddCategory()
    }
    
    private func cancelAddCategory() {
        showingAddCategory = false
        newCategoryName = ""
        if let firstColor = availableColors.first {
            selectedColorId = firstColor.id
        }
        selectedIcon = "folder.fill"
    }
}

struct CategoryManagementRowView: View {
    let category: Category
    let todoCount: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: category.systemIcon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(category.swiftUIColor)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(category.swiftUIColor.opacity(0.15))
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(todoCount) tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete button (show for all categories, but disable if it's the last one)
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
            .help("Delete category")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(category.swiftUIColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    CategoryManagementView()
        .environmentObject(TodoStore())
        .frame(width: 450, height: 550)
}