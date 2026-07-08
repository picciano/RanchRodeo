import SwiftUI

struct TeamCard: View {
    let team: Team

    @AppStorage("eventFormat") private var eventFormat: EventFormat = TeamSettings.defaultFormat

    // Show at least the configured team size, but expand if a team was hand-edited
    // to hold more riders so none are hidden.
    private var slotCount: Int {
        max(eventFormat.teamSize, team.riders.count)
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
        Text(rider.displayName + categorySuffix(for: rider))
            .foregroundStyle(rider.isWaiverSigned ? Color.primary : Color.red)
    }

    private func categorySuffix(for rider: Rider) -> String {
        // Round-robin ignores parent/child, so don't tag riders with (P)/(C).
        guard team.group == nil else { return "" }
        let code = rider.categoryCode
        return code.isEmpty ? "" : " (\(code))"
    }
}
