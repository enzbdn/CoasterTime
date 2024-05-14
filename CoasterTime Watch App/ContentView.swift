import SwiftUI

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
    
    func fetchData(for parkName: String) {
        guard let parkID = ParkList[parkName] else {
            DispatchQueue.main.async {
                self.errorMessage = "Park ID not found for \(parkName)"
            }
            return
        }
        
        guard let url = URL(string: "https://queue-times.com/parks/\(parkID)/queue_times.json") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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

struct ParkSelectionView: View {
    @StateObject private var viewModel = RideViewModel()
    @State private var selectedPark = "Disneyland Paris"
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select a Park", selection: $selectedPark) {
                    ForEach(ParkList.keys.sorted(), id: \.self) { parkName in
                        Text(parkName).tag(parkName)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
                
                Button(action: {
                    viewModel.fetchData(for: selectedPark)
                }) {
                    Text("Show Rides")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.rides) { ride in
                        VStack(alignment: .leading) {
                            Text(ride.name)
                                .font(.headline)
                            Text("Wait Time: \(ride.waitTime ?? 0) minutes")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Park Selector")
        }
    }
}

struct ContentView: View {
    var body: some View {
        ParkSelectionView()
    }
}

#Preview {
    ContentView()
}
