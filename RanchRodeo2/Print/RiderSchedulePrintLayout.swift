import SwiftUI

/// Builds the header and grid-rows for the rider schedule printout. Riders are laid
/// out in a fixed number of columns; each grid-row is one paginatable unit so pages
/// break cleanly between rows. Assembled by `PaginatedPrintDocument`.
enum RiderSchedulePrintLayout {
    static let columns = 3
    private static let cellSpacing: CGFloat = 8

    static func header() -> some View {
        HStack {
            Text("Rider Schedule")
                .font(.system(size: 12, weight: .semibold))
            Spacer()
            Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }

    /// Splits riders into rows of `columns` for pagination.
    static func rows(_ riders: [Rider]) -> [[Rider]] {
        stride(from: 0, to: riders.count, by: columns).map {
            Array(riders[$0..<min($0 + columns, riders.count)])
        }
    }

    /// One row of the grid: up to `columns` rider cells, padded with empty slots so
    /// a partial final row keeps the same column widths as full rows.
    static func gridRow(_ riders: [Rider], isRoundRobin: Bool) -> some View {
        HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(Array(riders.enumerated()), id: \.element.id) { _, rider in
                riderCell(rider, isRoundRobin: isRoundRobin)
            }
            ForEach(riders.count..<columns, id: \.self) { _ in
                Color.clear.frame(maxWidth: .infinity)
            }
        }
        // Hug content vertically so a row can't absorb the page's leftover space.
        // Without this the cells' inner Spacer makes each row greedy, and on a
        // partial (last) page the blocks balloon to fill the sheet.
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Cell

    private static func riderCell(_ rider: Rider, isRoundRobin: Bool) -> some View {
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
    private static func standardTeams(_ rider: Rider) -> some View {
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
    private static func groupColumns(_ rider: Rider) -> some View {
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
