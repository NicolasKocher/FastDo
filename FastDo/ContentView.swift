//
//  ContentView.swift
//  FastDo
//
//  Created by Nicolas Kocher on 25.08.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var todoStore: TodoStore
    @State private var newTodoText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingSettings = false
    @State private var isHovering = false
    
    private let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
                .background(Color.secondary.opacity(0.3))
            
            categoryTabs
            
            if todoStore.todosForSelectedCategory.isEmpty {
                emptyStateView
            } else {
                todoListView
            }
            
            if todoStore.hasCompletedTodos {
                footerView
            }
        }
        .frame(width: 400, height: 450)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.textBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Title and controls
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FastDo")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let category = todoStore.selectedCategory {
                        HStack(spacing: 6) {
                            Image(systemName: category.systemIcon)
                                .font(.caption)
                                .foregroundColor(category.swiftUIColor)
                            
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Categories button
                    Button {
                        WindowManager.shared.openCategoryWindow(todoStore: todoStore)
                    } label: {
                        Image(systemName: "folder")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.accentColor)
                    
                    // Settings button
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                    .popover(isPresented: $showingSettings) {
                        SettingsView()
                            .frame(width: 300, height: 200)
                    }
                }
            }
            
            // Input field with beautiful styling
            HStack(spacing: 12) {
                TextField("Add a new task (try 'Call Max tomorrow 2pm')...", text: $newTodoText)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        addTodo()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isTextFieldFocused ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                    .shadow(color: isTextFieldFocused ? Color.accentColor.opacity(0.2) : Color.clear, radius: 4, x: 0, y: 2)
                
                Button {
                    addTodo()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
                .disabled(newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                .scaleEffect(isHovering ? 1.05 : 1.0)
                .onHover { hovering in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isHovering = hovering
                    }
                }
            }
            
            // Stats
            if !todoStore.todosForSelectedCategory.isEmpty {
                HStack {
                    Text(todoStore.statsText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 12) {
                    ForEach(todoStore.categories) { category in
                        CategoryTab(
                            category: category,
                            isSelected: todoStore.selectedCategoryId == category.id,
                            todoCount: todoStore.todos.filter { $0.categoryId == category.id }.count
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                todoStore.selectCategory(category.id)
                                // Scroll to selected category
                                proxy.scrollTo(category.id, anchor: .center)
                            }
                        }
                        .id(category.id) // Important for scrollTo to work
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: 60)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            .overlay(
                // Visual indicators for scrollability
                HStack {
                    // Left fade
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(NSColor.controlBackgroundColor).opacity(0.6),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 15)
                    .allowsHitTesting(false)
                    
                    Spacer()
                    
                    // Right fade
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color(NSColor.controlBackgroundColor).opacity(0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 15)
                    .allowsHitTesting(false)
                }
            )
            .onAppear {
                // Scroll to selected category on appear
                if let selectedId = todoStore.selectedCategoryId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(selectedId, anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            if let category = todoStore.selectedCategory {
                VStack(spacing: 12) {
                    Image(systemName: category.systemIcon)
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(category.swiftUIColor.opacity(0.6))
                    
                    Text("No tasks in \(category.name)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Add your first task above to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    // MARK: - Todo List
    private var todoListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(todoStore.todosForSelectedCategory) { todo in
                    TodoRowView(
                        todo: todo,
                        todoStore: todoStore,
                        relativeDateFormatter: relativeDateFormatter
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.clear)
    }
    
    // MARK: - Footer
    private var footerView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.secondary.opacity(0.3))
            
            HStack {
                Spacer()
                Button("Clear Completed") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        todoStore.clearCompleted()
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        }
    }
    
    private func addTodo() {
        let text = newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            todoStore.addTodo(text)
            newTodoText = ""
            isTextFieldFocused = true
        }
    }
}

// MARK: - Category Tab Component
struct CategoryTab: View {
    let category: Category
    let isSelected: Bool
    let todoCount: Int
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Image(systemName: category.systemIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : category.swiftUIColor)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if todoCount > 0 {
                    Text("\(todoCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? category.swiftUIColor : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.9) : category.swiftUIColor)
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? category.swiftUIColor : Color.clear)
                    .overlay(
                        Capsule()
                            .stroke(category.swiftUIColor, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Enhanced Todo Row
struct TodoRowView: View {
    let todo: Todo
    let todoStore: TodoStore
    let relativeDateFormatter: RelativeDateTimeFormatter
    
    @State private var isEditing = false
    @State private var editText = ""
    @FocusState private var isEditFieldFocused: Bool
    @State private var isHovering = false
    
    private var category: Category? {
        todoStore.categories.first { $0.id == todo.categoryId }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    todoStore.toggleTodo(todo)
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(todo.isCompleted ? .green : category?.swiftUIColor ?? .accentColor)
            }
            .buttonStyle(.plain)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                if isEditing {
                    TextField("Task title", text: $editText)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($isEditFieldFocused)
                        .onSubmit {
                            saveEdit()
                        }
                        .onKeyPress(.escape) {
                            cancelEdit()
                            return .handled
                        }
                        .onAppear {
                            editText = todo.title
                            isEditFieldFocused = true
                        }
                } else {
                    Text(todo.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                        .strikethrough(todo.isCompleted)
                        .opacity(todo.isCompleted ? 0.6 : 1.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .onTapGesture {
                            startEditing()
                        }
                }
                
                // Metadata row
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text("added \(relativeDateFormatter.localizedString(for: todo.createdAt, relativeTo: Date()))")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text("due \(relativeDateFormatter.localizedString(for: dueDate, relativeTo: Date()))")
                                .font(.caption2)
                        }
                        .foregroundColor(dueDate < Date() ? .red : .orange)
                    }
                    
                    Spacer()
                    
                    if let category = category {
                        HStack(spacing: 4) {
                            Image(systemName: category.systemIcon)
                                .font(.system(size: 10))
                            Text(category.name)
                                .font(.caption2)
                        }
                        .foregroundColor(category.swiftUIColor)
                    }
                }
            }
            
            // Delete button (shown on hover)
            if isHovering {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        todoStore.deleteTodo(todo)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(category?.swiftUIColor.opacity(0.3) ?? Color.clear, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovering = hovering
            }
        }
        .onChange(of: isEditFieldFocused) { _, newValue in
            if !newValue && isEditing {
                saveEdit()
            }
        }
    }
    
    private func startEditing() {
        isEditing = true
        editText = todo.title
    }
    
    private func saveEdit() {
        let trimmedText = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            todoStore.updateTodo(todo, title: trimmedText)
        }
        isEditing = false
    }
    
    private func cancelEdit() {
        isEditing = false
        editText = todo.title
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoStore())
}
