import SwiftUI
import SwiftData

struct RosterView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Rider.firstName), SortDescriptor(\Rider.lastName)])
    private var riders: [Rider]

    @AppStorage("teamSize") private var teamSize = TeamSettings.defaultTeamSize

    @State private var newRiderSheet: NewRiderSheet?
    @State private var pendingNewRider: Rider?
    @State private var showClearConfirmation = false
    @State private var editMode: EditMode = .inactive

    private struct NewRiderSheet: Identifiable {
        let id = UUID()
        let rider: Rider
    }

    var body: some View {
        NavigationStack {
            Group {
                if riders.isEmpty {
                    ContentUnavailableView(
                        "No Riders",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Tap + to add your first rider.")
                    )
                } else {
                    List {
                        Section("Summary") {
                            summaryRow("Number of Riders", value: riders.activeRiders.count)
                            summaryRow("Total Rides", value: riders.totalRides)
                            summaryRow("Number of Teams", value: riders.numberOfTeams(teamSize: teamSize))
                        }

                        ForEach(riders) { rider in
                            NavigationLink {
                                RiderEditorView(rider: rider)
                            } label: {
                                RiderRow(rider: rider)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    RosterStore(modelContext: modelContext).setActive(!rider.isActive, for: rider)
                                } label: {
                                    if rider.isActive {
                                        Label("Deactivate", systemImage: "person.slash")
                                    } else {
                                        Label("Activate", systemImage: "person.fill.checkmark")
                                    }
                                }
                                .tint(rider.isActive ? .orange : .green)
                            }
                        }
                        .onDelete(perform: delete)

                        if editMode.isEditing {
                            Section {
                                Button(role: .destructive) {
                                    showClearConfirmation = true
                                } label: {
                                    Label("Clear All Riders", systemImage: "trash")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                        }
                    }
                    .environment(\.editMode, $editMode)
                }
            }
            .navigationTitle("Roster")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addRider) {
                        Label("Add Rider", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(editMode.isEditing ? "Done" : "Edit") {
                        withAnimation {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    }
                }
            }
            .sheet(item: $newRiderSheet, onDismiss: discardIfEmpty) { sheet in
                newRiderSheetContent(for: sheet)
            }
            .confirmationDialog(
                "Clear all riders and teams?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Riders", role: .destructive) {
                    RosterStore(modelContext: modelContext).clearRoster()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes \(riders.count) rider\(riders.count == 1 ? "" : "s") and any generated teams. This cannot be undone.")
            }
        }
    }

    private func summaryRow(_ title: String, value: Int) -> some View {
        LabeledContent(title) {
            Text("\(value)")
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private func newRiderSheetContent(for sheet: NewRiderSheet) -> some View {
        let stack = NavigationStack {
            RiderEditorView(rider: sheet.rider, focusNameOnAppear: true)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            newRiderSheet = nil
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .destructive) {
                            modelContext.delete(sheet.rider)
                            pendingNewRider = nil
                            newRiderSheet = nil
                        }
                    }
                }
        }
        .presentationDetents([.large])

        if #available(iOS 18.0, *) {
            stack.presentationSizing(.page)
        } else {
            stack
        }
    }

    private func addRider() {
        let rider = Rider()
        modelContext.insert(rider)
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save new rider: \(error)")
        }
        pendingNewRider = rider
        newRiderSheet = NewRiderSheet(rider: rider)
    }

    private func discardIfEmpty() {
        guard let rider = pendingNewRider else { return }
        if !rider.hasMeaningfulName {
            modelContext.delete(rider)
        }
        pendingNewRider = nil
    }

    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(riders[offset])
        }
    }
}

#Preview {
    RosterView()
        .modelContainer(for: [Rider.self, Team.self], inMemory: true)
}
