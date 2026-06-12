import SwiftUI
import SwiftData

struct EditTeamView: View {
    @Bindable var team: Team
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Team.number)])
    private var allTeams: [Team]

    var body: some View {
        Form {
            Section("Riders") {
                if team.riders.isEmpty {
                    Text("No riders assigned.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(team.riders) { rider in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rider.displayName)
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
                            Menu {
                                let others = allTeams.filter { $0 !== team }
                                if others.isEmpty {
                                    Text("No other teams")
                                } else {
                                    ForEach(others) { other in
                                        Button("Move to Team \(other.number)") {
                                            move(rider: rider, to: other)
                                        }
                                    }
                                }
                                Divider()
                                Button("Remove from team", role: .destructive) {
                                    remove(rider: rider)
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.large)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Section("Warnings") {
                WarningsListView(team: team)
            }
        }
        .navigationTitle("Edit Team \(team.number)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func move(rider: Rider, to destination: Team) {
        team.riders.removeAll { $0 === rider }
        if !destination.riders.contains(where: { $0 === rider }) {
            destination.riders.append(rider)
        }
        persist()
    }

    private func remove(rider: Rider) {
        team.riders.removeAll { $0 === rider }
        persist()
    }

    private func persist() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save team edit: \(error)")
        }
    }
}
