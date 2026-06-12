import SwiftUI

struct RiderScheduleCard: View {
    let rider: Rider
    let teamSlots: Int

    private var sortedTeams: [Team] {
        rider.teams.sorted { $0.number < $1.number }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rider.displayName)
                .font(.title3.bold())
                .foregroundStyle(rider.isWaiverSigned ? Color.primary : Color.red)
            Divider()
            ForEach(0..<teamSlots, id: \.self) { index in
                teamRow(at: index)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
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
