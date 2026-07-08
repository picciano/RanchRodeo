import SwiftUI
import SwiftData

struct TeamsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Team.number)])
    private var teams: [Team]

    @Query private var allRiders: [Rider]

    @AppStorage("eventFormat") private var eventFormat: EventFormat = TeamSettings.defaultFormat

    @State private var isGenerating = false
    @State private var showEmptyRosterAlert = false
    @State private var showRoundRobinCountAlert = false
    @State private var showRegenerateConfirmation = false
    @State private var showPrintPreview = false

    var body: some View {
        Group {
            if teams.isEmpty {
                ContentUnavailableView(
                    "No Teams",
                    systemImage: "square.grid.3x3",
                    description: Text("Tap Generate to build teams from the roster.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                        ForEach(teams) { team in
                            NavigationLink(value: team.id) {
                                TeamCard(team: team)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Teams")
        .navigationDestination(for: Team.ID.self) { id in
            if let team = teams.first(where: { $0.id == id }) {
                EditTeamView(team: team)
            } else {
                ContentUnavailableView("Team not found", systemImage: "questionmark")
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: generate) {
                    Label("Generate", systemImage: "wand.and.stars")
                }
                .disabled(isGenerating)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showPrintPreview = true
                } label: {
                    Label("Print", systemImage: "printer")
                }
                .disabled(teams.isEmpty)
            }
        }
        .sheet(isPresented: $showPrintPreview) {
            PrintPreviewView(teams: teams)
        }
        .alert("Add Riders First", isPresented: $showEmptyRosterAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Add at least one active rider to the roster before generating teams.")
        }
        .alert("Round Robin Needs 28 Riders", isPresented: $showRoundRobinCountAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A round robin event requires exactly \(RoundRobinDesign.riderCount) active riders. You currently have \(allRiders.activeRiders.count). Adjust the roster or change the event type in Settings.")
        }
        .confirmationDialog(
            "Regenerate teams?",
            isPresented: $showRegenerateConfirmation,
            titleVisibility: .visible
        ) {
            Button("Regenerate Teams", role: .destructive) {
                performGenerate()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This replaces the current \(teams.count) team\(teams.count == 1 ? "" : "s") with a fresh set. Any manual edits to team assignments will be lost.")
        }
    }

    private func generate() {
        let activeCount = allRiders.activeRiders.count
        if eventFormat.isRoundRobin {
            guard activeCount == RoundRobinDesign.riderCount else {
                showRoundRobinCountAlert = true
                return
            }
        } else {
            guard activeCount > 0 else {
                showEmptyRosterAlert = true
                return
            }
        }
        if !teams.isEmpty {
            showRegenerateConfirmation = true
            return
        }
        performGenerate()
    }

    private func performGenerate() {
        isGenerating = true
        defer { isGenerating = false }
        let store = RosterStore(modelContext: modelContext)
        store.regenerateTeams(rng: SystemRandomNumberGenerator())
    }
}

#Preview {
    NavigationStack {
        TeamsView()
    }
    .modelContainer(for: [Rider.self, Team.self], inMemory: true)
}
