import SwiftUI

struct RiderRow: View {
    let rider: Rider

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(rider.displayName)
                    .font(.body)
                    .foregroundStyle(rider.isWaiverSigned ? Color.primary : Color.red)
                let labels = rider.categoryLabels
                if !labels.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(labels, id: \.self) { label in
                            Text(label)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.18), in: Capsule())
                        }
                    }
                }
            }
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
