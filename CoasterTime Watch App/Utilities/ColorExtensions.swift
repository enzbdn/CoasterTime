import SwiftUI

extension Color {
    static func waitTimeColor(minutes: Int) -> Color {
        switch minutes {
        case 0...15: return .green
        case 16...30: return .yellow
        case 31...60: return .orange
        default: return .red
        }
    }
}
