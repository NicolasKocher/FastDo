import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var color: String // Store as hex string for Codable compatibility
    var systemIcon: String
    let isDefault: Bool
    let createdAt: Date
    
    init(name: String, color: Color = .blue, systemIcon: String = "folder.fill", isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.color = color.toHex()
        self.systemIcon = systemIcon
        self.isDefault = isDefault
        self.createdAt = Date()
    }
    
    var swiftUIColor: Color {
        Color(hex: color) ?? .blue
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, color, systemIcon, isDefault, createdAt
    }
    
    static let defaultCategories: [Category] = [
        Category(name: "Personal", color: .blue, systemIcon: "person.fill", isDefault: true),
        Category(name: "Work", color: .orange, systemIcon: "briefcase.fill", isDefault: true),
        Category(name: "Shopping", color: .green, systemIcon: "cart.fill", isDefault: true),
        Category(name: "Health", color: .red, systemIcon: "heart.fill", isDefault: true)
    ]
}

// MARK: - Color Extensions
extension Color {
    func toHex() -> String {
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else { return "#007AFF" }
        
        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}