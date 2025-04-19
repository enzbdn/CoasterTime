import SwiftUI

struct RideDetailView: View {
    let ride: Ride
    let parkID: Int
    @StateObject private var viewModel = RideViewModel()
    @State private var isRefreshing = false
    @AppStorage("favorite-rides") private var favoriteRideIDs = ""
    
    private var isFavorite: Bool {
        favoriteRideIDs.split(separator: ",").map { String($0) }.contains(String(ride.id))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text(ride.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            viewModel.fetchData(for: parkID)
                            isRefreshing = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isRefreshing = false
                            }
                        }) {
                            Image(systemName: isRefreshing ? "arrow.triangle.2.circlepath.circle" : "arrow.clockwise")
                                .foregroundColor(.blue)
                                .font(.footnote)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .font(.footnote)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(5)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Wait Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(Color.waitTimeColor(minutes: ride.waitTime ?? 0))
                        
                        Text("\(ride.waitTime ?? 0) minutes")
                            .font(.headline)
                            .foregroundColor(Color.waitTimeColor(minutes: ride.waitTime ?? 0))
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 2)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: ride.isOpen == true ? "checkmark.circle" : "xmark.circle")
                            .foregroundColor(ride.isOpen == true ? .green : .red)
                        
                        Text(ride.isOpen == true ? "Open" : "Closed")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(ride.isOpen == true ? .green : .red)
                    }
                }
                .padding(.vertical, 2)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Ride Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleFavorite() {
        let rideID = String(ride.id)
        var favorites = favoriteRideIDs.split(separator: ",").map { String($0) }
        
        if isFavorite {
            favorites.removeAll { $0 == rideID }
        } else {
            favorites.append(rideID)
        }
        
        favoriteRideIDs = favorites.joined(separator: ",")
    }
    

}
