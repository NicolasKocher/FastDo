//
//  FastDoApp.swift
//  FastDo
//
//  Created by Nicolas Kocher on 25.08.25.
//

import SwiftUI
import KeyboardShortcuts
import AppKit

class WindowManager: ObservableObject {
    static let shared = WindowManager()
    
    func openCategoryWindow(todoStore: TodoStore) {
        let categoryWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 550),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        categoryWindow.title = "Categories"
        categoryWindow.center()
        categoryWindow.setFrameAutosaveName("CategoryWindow")
        categoryWindow.isReleasedWhenClosed = false
        
        let categoryView = CategoryManagementView()
            .environmentObject(todoStore)
        
        categoryWindow.contentView = NSHostingView(rootView: categoryView)
        categoryWindow.makeKeyAndOrderFront(nil)
    }
}

@main
struct FastDoApp: App {
    @StateObject private var todoStore = TodoStore()
    
    init() {
        setupGlobalShortcut()
    }
    
    var body: some Scene {
        MenuBarExtra("FastDo", systemImage: "checkmark.circle") {
            ContentView()
                .environmentObject(todoStore)
        }
        .menuBarExtraStyle(.window)
    }
    
    private func setupGlobalShortcut() {
        KeyboardShortcuts.onKeyDown(for: .toggleQuickAdd) {
            // Simply activate the application - this will bring focus to the menubar
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                
                // Try to bring any existing FastDo window to front
                for window in NSApp.windows {
                    if window.isVisible && window.canBecomeKey {
                        window.makeKeyAndOrderFront(nil)
                        return
                    }
                }
                
                // If no key window found, just activate the app which should show the menubar
                // User can then click the menubar icon manually
            }
        }
    }
}
