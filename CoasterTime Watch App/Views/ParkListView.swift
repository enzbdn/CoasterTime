import SwiftUI

struct ParkListView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var showFavoritesOnly = false
    
    var body: some View {
        List {
            if showFavoritesOnly && filteredParks.isEmpty {
                Text("No favorite parks")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(filteredParks) { park in
                    NavigationLink(destination: RideListView(parkID: park.id, parkName: park.name)) {
                        HStack {
                            Text(park.name)
                            Spacer()
                            if favoritesManager.isParkFavorite(park.id) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .swipeActions {
                        Button(favoritesManager.isParkFavorite(park.id) ? "Unfavorite" : "Favorite") {
                            favoritesManager.toggleParkFavorite(park.id)
                        }
                        .tint(.red)
                    }
                }
            }
        }
        .navigationTitle("Select a Park")
        .toolbar {
            Button {
                showFavoritesOnly.toggle()
            } label: {
                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
            }
        }
    }
    
    private var filteredParks: [Park] {
        showFavoritesOnly
            ? ParkData.parks.filter { favoritesManager.isParkFavorite($0.id) }
            : ParkData.parks
    }
}
