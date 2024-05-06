//
//  ContentView.swift
//  CoasterTime Watch App
//
//  Created by Enzo Bodin on 28/04/2024.
//

import SwiftUI

var ParkList: [String: Int] = ["Parc Astérix": 9, "Disneyland Paris": 4, "Disney Adventure World": 28]

struct Ride: Identifiable, Decodable {
    let id: Int
    let name: String
    let isOpen: Bool
    let waitTime: Int
    let lastUpdated: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, is_open, wait_time, last_updated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isOpen = (try container.decodeIfPresent(Bool.self, forKey: .is_open)) ?? false
        waitTime = (try container.decodeIfPresent(Int.self, forKey: .wait_time)) ?? -1
        lastUpdated = try container.decode(String.self, forKey: .last_updated)
    }
}

struct QueueData: Decodable {
    let rides: [Ride]
    
    private enum RootKeys: String, CodingKey {
        case rides
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        self.rides = try container.decode([Ride].self, forKey: .rides)
    }
}

class RideViewModel: ObservableObject {
    @Published var rides: [Ride] = []
    
    func fetchData(for parkName: String) {
        guard let parkID = ParkList[parkName] else {
            print("Park ID not found for \(parkName)")
            return
        }
    
        guard let url = URL(string: "https://queue-times.com/parks/\(parkID)/queue_times.json")
            else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let queueData = try JSONDecoder().decode(QueueData.self, from: data)
                var sortedRides = queueData.rides.sorted(by: { $0.waitTime > $1.waitTime })
                sortedRides = sortedRides.filter { $0.waitTime > 0 }
                DispatchQueue.main.async {
                    self.rides = sortedRides
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}


struct ContentView: View {
    @StateObject var viewModel = RideViewModel()
    
    var body: some View {
        VStack {
            List(viewModel.rides) { ride in
                VStack(alignment: .leading) {
                    Text(ride.name)
                    Text("Wait Time: \(ride.waitTime) minutes")
                }
            }
            
            Button(action: {
                viewModel.fetchData(for: "Parc Astérix")
            }) {
                Text("Refresh")
            }
        }
        .onAppear {
            viewModel.fetchData(for: "Parc Astérix")
        }
    }
}
#Preview {
    ContentView()
}
