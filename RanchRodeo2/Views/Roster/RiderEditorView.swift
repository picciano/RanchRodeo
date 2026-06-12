import SwiftUI
import SwiftData

struct RiderEditorView: View {
    @Bindable var rider: Rider

    var body: some View {
        Form {
            Section("Name") {
                TextField("First name", text: $rider.firstName)
                    .textInputAutocapitalization(.words)
                TextField("Last name", text: $rider.lastName)
                    .textInputAutocapitalization(.words)
            }

            Section("Status") {
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
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        let name = rider.fullName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "New Rider" : name
    }
}
