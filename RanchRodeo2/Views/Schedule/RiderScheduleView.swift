import SwiftUI
import SwiftData

struct RiderScheduleView: View {
    @Query(sort: [SortDescriptor(\Rider.firstName), SortDescriptor(\Rider.lastName)])
    private var riders: [Rider]

    @AppStorage("eventFormat") private var eventFormat: EventFormat = TeamSettings.defaultFormat

    @State private var showPrintPreview = false

    private var activeRiders: [Rider] { riders.activeRiders }

    /// Round-robin cards hold three group columns, so they need more width.
    private var columnMinWidth: CGFloat { eventFormat.isRoundRobin ? 320 : 220 }

    private var teamSlots: Int {
        max(2, activeRiders.map { $0.teams.count }.max() ?? 0)
    }

    private var anyRiderHasCategories: Bool {
        activeRiders.contains { !$0.categoryLabels.isEmpty }
    }

    var body: some View {
        Group {
            if activeRiders.isEmpty {
                ContentUnavailableView(
                    "No Riders",
                    systemImage: "calendar",
                    description: Text("Add riders in the Roster tab to see their schedule here.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: columnMinWidth), spacing: 12)], spacing: 12) {
                        ForEach(activeRiders) { rider in
                            NavigationLink {
                                RiderEditorView(rider: rider)
                            } label: {
                                RiderScheduleCard(
                                    rider: rider,
                                    teamSlots: teamSlots,
                                    reserveCategorySpace: anyRiderHasCategories,
                                    isRoundRobin: eventFormat.isRoundRobin
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showPrintPreview = true
                } label: {
                    Label("Print", systemImage: "printer")
                }
                .disabled(activeRiders.isEmpty)
            }
        }
        .sheet(isPresented: $showPrintPreview) {
            SchedulePrintPreviewView(riders: activeRiders)
        }
    }
}

#Preview {
    NavigationStack {
        RiderScheduleView()
    }
    .modelContainer(for: [Rider.self, Team.self], inMemory: true)
}
