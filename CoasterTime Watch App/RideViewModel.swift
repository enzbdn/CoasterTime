import Foundation

var ParkList: [String: Int] = ["Parc Astérix": 9, "Disneyland Paris": 4, "Disney Adventure World": 28]

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

class RideViewModel: ObservableObject {
    @Published var rides: [Ride] = []
    @Published var errorMessage: String?
    
    func fetchData(for parkID: Int) {
        guard let url = URL(string: "https://queue-times.com/parks/\(parkID)/queue_times.json") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error as? URLError, error.code == .cancelled {
                DispatchQueue.main.async {
                    self.errorMessage = "Request was cancelled"
                }
                return
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let parent = try JSONDecoder().decode(Parent.self, from: data)
                var allRides: [Ride] = parent.rides
                
                // If lands are present, append rides from lands
                for land in parent.lands {
                    allRides.append(contentsOf: land.rides)
                }
                
                allRides = allRides.sorted(by: { ($0.waitTime ?? 0) > ($1.waitTime ?? 0) })
                allRides = allRides.filter { $0.waitTime ?? 0 > 0 }
                
                DispatchQueue.main.async {
                    self.rides = allRides
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}
