import SwiftUI
import SwiftData

struct RiderScheduleView: View {
    @Query(sort: [SortDescriptor(\Rider.firstName), SortDescriptor(\Rider.lastName)])
    private var riders: [Rider]

    @State private var showPrintPreview = false

    private var teamSlots: Int {
        max(2, riders.map { $0.teams.count }.max() ?? 0)
    }

    private var anyRiderHasCategories: Bool {
        riders.contains { !$0.categoryLabels.isEmpty }
    }

    var body: some View {
        Group {
            if riders.isEmpty {
                ContentUnavailableView(
                    "No Riders",
                    systemImage: "calendar",
                    description: Text("Add riders in the Roster tab to see their schedule here.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                        ForEach(riders) { rider in
                            NavigationLink {
                                RiderEditorView(rider: rider)
                            } label: {
                                RiderScheduleCard(
                                rider: rider,
                                teamSlots: teamSlots,
                                reserveCategorySpace: anyRiderHasCategories
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
                .disabled(riders.isEmpty)
            }
        }
        .sheet(isPresented: $showPrintPreview) {
            SchedulePrintPreviewView(riders: riders)
        }
    }
}

#Preview {
    NavigationStack {
        RiderScheduleView()
    }
    .modelContainer(for: [Rider.self, Team.self], inMemory: true)
}
