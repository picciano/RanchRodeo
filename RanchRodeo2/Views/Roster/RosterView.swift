import SwiftUI
import SwiftData

struct RosterView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Rider.firstName), SortDescriptor(\Rider.lastName)])
    private var riders: [Rider]

    @State private var newRiderSheet: NewRiderSheet?
    @State private var pendingNewRider: Rider?

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
                        ForEach(riders) { rider in
                            NavigationLink {
                                RiderEditorView(rider: rider)
                            } label: {
                                RiderRow(rider: rider)
                            }
                        }
                        .onDelete(perform: delete)
                    }
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
                    EditButton()
                }
            }
            .sheet(item: $newRiderSheet, onDismiss: discardIfEmpty) { sheet in
                newRiderSheetContent(for: sheet)
            }
        }
    }

    @ViewBuilder
    private func newRiderSheetContent(for sheet: NewRiderSheet) -> some View {
        let stack = NavigationStack {
            RiderEditorView(rider: sheet.rider)
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
        try? modelContext.save()
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
