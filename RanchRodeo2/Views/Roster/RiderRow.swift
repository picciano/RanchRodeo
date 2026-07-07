import SwiftUI

struct RiderRow: View {
    let rider: Rider

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(rider.displayName)
                    .font(.body)
                    .strikethrough(!rider.isActive)
                    .foregroundStyle(nameColor)
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
            if let preferredTeam = rider.preferredTeamNumber {
                Text("Team \(preferredTeam)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("\(rider.numberOfRides) rides")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    /// Inactive riders are de-emphasized; active riders keep the waiver-status cue.
    private var nameColor: Color {
        guard rider.isActive else { return .secondary }
        return rider.isWaiverSigned ? .primary : .red
    }
}
