import Foundation
import Combine

enum LoadingState {
    case idle
    case loading
    case loaded
    case error(String)
}

class RideViewModel: ObservableObject {
    @Published var rides: [Ride] = []
    @Published var loadingState: LoadingState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData(for parkID: Int) {
        guard let url = URL(string: "https://queue-times.com/parks/\(parkID)/queue_times.json") else {
            loadingState = .error("Invalid URL")
            return
        }
        
        loadingState = .loading
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Parent.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loadingState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] parent in
                    var allRides = parent.rides
                    
                    for land in parent.lands {
                        allRides.append(contentsOf: land.rides)
                    }
                    
                    allRides = allRides
                        .sorted(by: { ($0.waitTime ?? 0) > ($1.waitTime ?? 0) })
                        .filter { $0.waitTime ?? 0 > 0 }
                    
                    self?.rides = allRides
                    self?.loadingState = .loaded
                }
            )
            .store(in: &cancellables)
    }
}
