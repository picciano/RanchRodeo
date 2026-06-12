import SwiftUI
import SwiftData

struct RiderEditorView: View {
    @Bindable var rider: Rider

    @Query(
        filter: #Predicate<Rider> { $0.isParent },
        sort: [SortDescriptor(\Rider.firstName), SortDescriptor(\Rider.lastName)]
    )
    private var parentOptions: [Rider]

    var body: some View {
        Form {
            Section("Name") {
                TextField("First name", text: $rider.firstName)
                    .textInputAutocapitalization(.words)
                TextField("Last name", text: $rider.lastName)
                    .textInputAutocapitalization(.words)
            }

            Section("Status") {
                Toggle("Child", isOn: $rider.isChild)
                Toggle("Parent", isOn: $rider.isParent)
                Toggle("Waiver signed", isOn: $rider.isWaiverSigned)
            }

            Section("Rides") {
                Stepper(value: $rider.numberOfRides, in: 2...5) {
                    HStack {
                        Text("Number of rides")
                        Spacer()
                        Text("\(rider.numberOfRides)")
                            .foregroundStyle(.secondary)
                    }
                }
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
