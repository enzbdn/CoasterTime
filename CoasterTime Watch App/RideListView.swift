import SwiftUI

struct RideListView: View {
    @StateObject private var viewModel = RideViewModel()
    let parkID: Int
    let parkName: String

    var body: some View {
        VStack {
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

        .navigationTitle(parkName)
        .onAppear {
            viewModel.fetchData(for: parkID)
        }
        Button(action: {
            viewModel.fetchData(for: parkID)
        }) {
            Text("Refresh")
        }
    }
}

#Preview {
    RideListView(parkID: 9, parkName: "Parc Astérix")
}
