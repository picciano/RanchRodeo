import SwiftUI

struct TeamCard: View {
    let team: Team

    @AppStorage("teamSize") private var teamSize = TeamSettings.defaultTeamSize

    // Show at least the configured team size, but expand if a team was hand-edited
    // to hold more riders so none are hidden.
    private var slotCount: Int {
        max(teamSize, team.riders.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Team \(team.number)")
                    .font(.title3.bold())
                Spacer()
                if !team.warnings.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("\(team.warnings.count) warnings")
                }
            }
            Divider()
            ForEach(0..<slotCount, id: \.self) { i in
                if i < team.riders.count {
                    riderLine(team.riders[i])
                } else {
                    Text("AVAILABLE")
                        .font(.callout.italic())
                        .foregroundStyle(Color.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func riderLine(_ rider: Rider) -> some View {
        Text(rider.displayName + ridesSuffix(for: rider))
            .foregroundStyle(rider.isWaiverSigned ? Color.primary : Color.red)
    }

    private func ridesSuffix(for rider: Rider) -> String {
        guard rider.numberOfRides > 2 else { return "" }
        let code = rider.categoryCode
        return code.isEmpty ? " (\(rider.numberOfRides))" : " (\(rider.numberOfRides) \(code))"
    }
}
