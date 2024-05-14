import SwiftUI

struct ParkListView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(ParkList.keys.sorted(), id: \.self) { parkName in
                    if let parkID = ParkList[parkName] {
                        NavigationLink(destination: RideListView(parkID: parkID, parkName: parkName)) {
                            Text(parkName)
                        }
                    }
                }
            }
            .navigationTitle("Select a Park")
        }
    }
}

#Preview {
    ParkListView()
}
