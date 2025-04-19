import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favoriteParks: [Int] = []
    @Published var favoriteRides: [Int] = []
    
    @AppStorage("favorite-parks") private var favoriteParkIDsStorage = ""
    @AppStorage("favorite-rides") private var favoriteRideIDsStorage = ""
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        favoriteParks = favoriteParkIDsStorage.split(separator: ",").compactMap { Int($0) }
        favoriteRides = favoriteRideIDsStorage.split(separator: ",").compactMap { Int($0) }
    }
    
    func isParkFavorite(_ parkID: Int) -> Bool {
        favoriteParks.contains(parkID)
    }
    
    func toggleParkFavorite(_ parkID: Int) {
        if isParkFavorite(parkID) {
            favoriteParks.removeAll { $0 == parkID }
        } else {
            favoriteParks.append(parkID)
        }
        favoriteParkIDsStorage = favoriteParks.map { String($0) }.joined(separator: ",")
    }
    
    func isRideFavorite(_ rideID: Int) -> Bool {
        favoriteRides.contains(rideID)
    }
    
    func toggleRideFavorite(_ rideID: Int) {
        if isRideFavorite(rideID) {
            favoriteRides.removeAll { $0 == rideID }
        } else {
            favoriteRides.append(rideID)
        }
        favoriteRideIDsStorage = favoriteRides.map { String($0) }.joined(separator: ",")
    }
}
