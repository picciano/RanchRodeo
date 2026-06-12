import SwiftUI

struct RiderRow: View {
    let rider: Rider

    var body: some View {
        HStack(spacing: 12) {
            Text(rider.displayName)
                .font(.body)
                .foregroundStyle(rider.isWaiverSigned ? Color.primary : Color.red)
            Spacer()
            if rider.numberOfRides != 2 {
                Text("\(rider.numberOfRides) rides")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
