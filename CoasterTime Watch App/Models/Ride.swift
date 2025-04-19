import Foundation

struct Parent: Decodable {
    let lands: [Land]
    let rides: [Ride]
}

struct Land: Decodable, Identifiable {
    let id: Int
    let name: String
    let rides: [Ride]
}

struct Ride: Decodable, Identifiable {
    let id: Int
    let name: String
    let isOpen: Bool?
    let waitTime: Int?
    let lastUpdated: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name
        case isOpen = "is_open"
        case waitTime = "wait_time"
        case lastUpdated = "last_updated"
    }
}
