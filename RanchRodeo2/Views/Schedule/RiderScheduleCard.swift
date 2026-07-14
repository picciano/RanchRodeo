import SwiftUI

struct RiderScheduleCard: View {
    let rider: Rider
    let teamSlots: Int
    let reserveCategorySpace: Bool
    var isRoundRobin: Bool = false

    private var sortedTeams: [Team] {
        rider.teams.sorted { $0.number < $1.number }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rider.displayName)
                .font(.title3.bold())
                .foregroundStyle(rider.isWaiverSigned ? Color.primary : Color.red)
            Divider()
            if isRoundRobin {
                groupColumns
            } else {
                if reserveCategorySpace {
                    categoryRow
                }
                ForEach(0..<teamSlots, id: \.self) { index in
                    teamRow(at: index)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }

    /// Round-robin layout: the rider's teams laid out in three columns (one per
    /// group) to keep the card compact rather than a tall list of nine teams.
    private var groupColumns: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(RoundRobinDesign.Group.allCases) { group in
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    let teams = rider.teams
                        .filter { $0.group == group.rawValue }
                        .sorted { $0.number < $1.number }
                    ForEach(teams) { team in
                        Text("Team \(team.number)")
                            .font(.callout)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var categoryRow: some View {
        let labels = rider.categoryLabels
        if labels.isEmpty {
            // Invisible placeholder so cards without categories still match height.
            Text("Placeholder")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .hidden()
        } else {
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

    @ViewBuilder
    private func teamRow(at index: Int) -> some View {
        if index < sortedTeams.count {
            Text("Team \(sortedTeams[index].number)")
        } else if index == 0 && sortedTeams.isEmpty {
            Text("No teams assigned")
                .italic()
                .foregroundStyle(.secondary)
        } else {
            // Invisible placeholder to keep cards the same height as the tallest one.
            Text("Team 0").hidden()
        }
    }
}
