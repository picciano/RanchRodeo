import SwiftUI
import SwiftData

struct RiderEditorView: View {
    @Bindable var rider: Rider

    @Environment(\.modelContext) private var modelContext

    @AppStorage("eventFormat") private var eventFormat: EventFormat = TeamSettings.defaultFormat

    @Query(
        filter: #Predicate<Rider> { $0.isParent },
        sort: [SortDescriptor(\Rider.firstName), SortDescriptor(\Rider.lastName)]
    )
    private var parentOptions: [Rider]

    @Query private var allRiders: [Rider]

    /// The number of teams the current roster will produce at the configured size,
    /// used to bound the preferred-team picker. At least 1 so a preference can be set.
    private var teamCount: Int {
        max(1, allRiders.numberOfTeams(teamSize: eventFormat.teamSize))
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("First name", text: $rider.firstName)
                    .textInputAutocapitalization(.words)
                TextField("Last name", text: $rider.lastName)
                    .textInputAutocapitalization(.words)
            }

            Section {
                Toggle("Active", isOn: activeBinding)
            } footer: {
                Text("Inactive riders stay on the roster but are left out of team generation, the totals, and all printouts.")
            }

            Section("Status") {
                Toggle("Child", isOn: $rider.isChild)
                Toggle("Parent", isOn: $rider.isParent)
                Toggle("Waiver signed", isOn: $rider.isWaiverSigned)
            }

            Section("Rides") {
                Stepper(value: $rider.numberOfRides, in: 1...99) {
                    HStack {
                        Text("Number of rides")
                        Spacer()
                        Text("\(rider.numberOfRides)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Picker("Preferred team", selection: $rider.preferredTeamNumber) {
                    Text("No preference").tag(Int?.none)
                    ForEach(1...teamCount, id: \.self) { number in
                        Text("Team \(number)").tag(Int?(number))
                    }
                }
            } header: {
                Text("Preferred Team")
            } footer: {
                Text("Seats this rider on the chosen team first, before other rules. If the team is full or no longer exists when teams are generated, the rider is assigned normally.")
            }

            if rider.isChild {
                let candidates = parentOptions.filter { $0 !== rider }
                Section {
                    if candidates.isEmpty {
                        Text("No riders marked as parents yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(candidates) { parent in
                            parentToggleRow(parent)
                        }
                    }
                } header: {
                    Text("Parents")
                } footer: {
                    if !candidates.isEmpty {
                        Text("Tap a name to add or remove that parent. Selected parents show a checkmark.")
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Routes the Active toggle through RosterStore so deactivating also clears the
    /// rider's team assignments and payouts.
    private var activeBinding: Binding<Bool> {
        Binding(
            get: { rider.isActive },
            set: { RosterStore(modelContext: modelContext).setActive($0, for: rider) }
        )
    }

    private func parentToggleRow(_ parent: Rider) -> some View {
        let isSelected = rider.parents.contains { $0 === parent }
        return Button {
            if isSelected {
                rider.parents.removeAll { $0 === parent }
            } else {
                rider.parents.append(parent)
            }
        } label: {
            HStack {
                Text(parent.fullName.trimmingCharacters(in: .whitespaces).isEmpty ? "New Rider" : parent.fullName)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
    }

    private var navigationTitle: String {
        let name = rider.fullName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "New Rider" : name
    }
}
