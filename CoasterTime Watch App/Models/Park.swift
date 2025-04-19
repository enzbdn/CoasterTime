import Foundation

struct Park: Identifiable {
    let id: Int
    let name: String
}

struct ParkData {
    static let parks = [
        Park(id: 9, name: "Parc Astérix"),
        Park(id: 4, name: "Disneyland Paris"),
        Park(id: 28, name: "Disney Adventure World")
    ]
}
