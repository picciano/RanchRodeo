import SwiftUI
import SwiftData

struct TeamsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Team.number)])
    private var teams: [Team]

    @Query private var allRiders: [Rider]

    @State private var isGenerating = false
    @State private var showEmptyRosterAlert = false
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
            ToolbarItem(placement: .secondaryAction) {
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
            Text("Add at least one rider to the roster before generating teams.")
        }
    }

    private func generate() {
        guard !allRiders.isEmpty else {
            showEmptyRosterAlert = true
            return
        }
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
