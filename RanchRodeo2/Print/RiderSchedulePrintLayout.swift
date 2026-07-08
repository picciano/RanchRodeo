import SwiftUI

struct RiderSchedulePrintLayout: View {
    static let pageSize = CGSize(width: 612, height: 792) // US Letter @ 72 DPI
    static let ridersPerPage = 24
    static let columns = 3

    let riders: [Rider]
    var isRoundRobin: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Rider Schedule")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: RiderSchedulePrintLayout.columns),
                spacing: 8
            ) {
                ForEach(riders) { rider in
                    riderCell(rider)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: RiderSchedulePrintLayout.pageSize.width, height: RiderSchedulePrintLayout.pageSize.height, alignment: .topLeading)
        .background(Color.white)
    }

    private func riderCell(_ rider: Rider) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rider.displayName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(rider.isWaiverSigned ? Color.black : Color.red)
                .lineLimit(1)
            if isRoundRobin {
                groupColumns(rider)
            } else {
                standardTeams(rider)
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(minHeight: 64, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private func standardTeams(_ rider: Rider) -> some View {
        let labels = rider.categoryLabels
        if !labels.isEmpty {
            Text(labels.joined(separator: ", "))
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        let sortedTeams = rider.teams.sorted { $0.number < $1.number }
        if sortedTeams.isEmpty {
            Text("No teams")
                .font(.system(size: 10))
                .italic()
                .foregroundStyle(.secondary)
        } else {
            ForEach(sortedTeams) { team in
                Text("Team \(team.number)")
                    .font(.system(size: 10))
                    .foregroundStyle(.black)
            }
        }
    }

    /// Round-robin: the rider's teams in three group columns to stay compact.
    private func groupColumns(_ rider: Rider) -> some View {
        HStack(alignment: .top, spacing: 6) {
            ForEach(RoundRobinDesign.Group.allCases) { group in
                VStack(alignment: .leading, spacing: 1) {
                    Text(group.rawValue)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                    let teams = rider.teams
                        .filter { $0.group == group.rawValue }
                        .sorted { $0.number < $1.number }
                    ForEach(teams) { team in
                        Text("\(team.number)")
                            .font(.system(size: 10))
                            .foregroundStyle(.black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
