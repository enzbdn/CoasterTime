import SwiftUI

struct RideListView: View {
    @StateObject private var viewModel = RideViewModel()
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var showFavoritesOnly = false
    @State private var isRefreshing = false
    let parkID: Int
    let parkName: String

    var body: some View {
        VStack {
            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView("Loading rides...")
            case .loaded:
                if filteredRides.isEmpty {
                    Text(showFavoritesOnly ? "No favorite rides" : "No rides with wait times")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(filteredRides) { ride in
                        NavigationLink(destination: RideDetailView(ride: ride, parkID: parkID)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ride.name)
                                        .font(.headline)
                                    HStack {
                                        Image(systemName: "clock").imageScale(.small)
                                        Text("\(ride.waitTime ?? 0) min").font(.subheadline)
                                    }
                                    .foregroundColor(Color.waitTimeColor(minutes: ride.waitTime ?? 0))
                                }
                                Spacer()
                                if favoritesManager.isRideFavorite(ride.id) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                        }
                        .swipeActions {
                            Button(favoritesManager.isRideFavorite(ride.id) ? "Unfavorite" : "Favorite") {
                                favoritesManager.toggleRideFavorite(ride.id)
                            }
                            .tint(.red)
                        }
                    }
                }
            case .error(let message):
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                        .padding()
                    Text(message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Button("Try Again") { viewModel.fetchData(for: parkID) }
                        .buttonStyle(.bordered)
                        .padding()
                }
            }
        }
        .navigationTitle(parkName)
        .onAppear { viewModel.fetchData(for: parkID) }
        .toolbar {
            HStack {
                Button {
                    showFavoritesOnly.toggle()
                } label: {
                    Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                        .imageScale(.medium)
                }
                
                Button {
                    viewModel.fetchData(for: parkID)
                    isRefreshing = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isRefreshing = false
                    }
                } label: {
                    Image(systemName: isRefreshing ? "arrow.triangle.2.circlepath.circle" : "arrow.clockwise")
                        .imageScale(.medium)
                }
            }
        }
    }
    

    
    private var filteredRides: [Ride] {
        showFavoritesOnly 
            ? viewModel.rides.filter { favoritesManager.isRideFavorite($0.id) }
            : viewModel.rides
    }
}
