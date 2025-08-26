import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                // Launch at Login
                HStack {
                    LaunchAtLogin.Toggle()
                    Spacer()
                }
                
                Divider()
                
                // Keyboard Shortcut
                VStack(alignment: .leading, spacing: 8) {
                    Text("Global Shortcut")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    KeyboardShortcuts.Recorder(for: .toggleQuickAdd) {
                        Text("Record shortcut...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Default: ⌥⌘T")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.1))
    }
}

extension KeyboardShortcuts.Name {
    static let toggleQuickAdd = Self("toggleQuickAdd", default: .init(.t, modifiers: [.option, .command]))
}

#Preview {
    SettingsView()
        .frame(width: 300, height: 200)
}