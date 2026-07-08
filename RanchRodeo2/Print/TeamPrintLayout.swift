import SwiftUI

struct TeamPrintLayout: View {
    static let pageSize = CGSize(width: 612, height: 792) // US Letter @ 72 DPI
    static let teamsPerPage = 12
    static let columns = 3
    static let rows = 4

    let teams: [Team]
    let showRiderDetails: Bool
    var heading: String = "Ranch Rodeo Teams"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(heading)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: TeamPrintLayout.columns),
                spacing: 8
            ) {
                ForEach(teams) { team in
                    teamCell(team)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: TeamPrintLayout.pageSize.width, height: TeamPrintLayout.pageSize.height, alignment: .topLeading)
        .background(Color.white)
    }

    private func teamCell(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Team \(team.number)")
                .font(.system(size: 13, weight: .bold))
            Divider()
            ForEach(0..<max(TeamSettings.teamSize, team.riders.count), id: \.self) { i in
                if i < team.riders.count {
                    riderLine(team.riders[i])
                } else {
                    Text("AVAILABLE")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.red)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(height: 160, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
        )
    }

    private func riderLine(_ rider: Rider) -> some View {
        let label: String
        let code = rider.categoryCode
        if showRiderDetails && !code.isEmpty {
            label = "\(rider.displayName) (\(code))"
        } else {
            label = rider.displayName
        }
        return Text(label)
            .font(.system(size: 11))
            .foregroundStyle(rider.isWaiverSigned ? Color.black : Color.red)
            .lineLimit(1)
    }
}
