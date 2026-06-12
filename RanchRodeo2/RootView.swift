import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    enum Section: String, Hashable, CaseIterable, Identifiable {
        case roster, teams, schedule, settings
        var id: String { rawValue }
        var label: String {
            switch self {
            case .roster: "Roster"
            case .teams: "Teams"
            case .schedule: "Schedule"
            case .settings: "Settings"
            }
        }
        var icon: String {
            switch self {
            case .roster: "person.2"
            case .teams: "square.grid.3x3"
            case .schedule: "calendar"
            case .settings: "gearshape"
            }
        }
    }

    @State private var selection: Section? = .roster

    var body: some View {
        NavigationSplitView {
            List(Section.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Label(section.label, systemImage: section.icon)
                }
            }
            .navigationTitle("Ranch Rodeo")
        } detail: {
            switch selection {
            case .roster:
                RosterView()
            case .teams:
                NavigationStack {
                    TeamsView()
                }
            case .schedule:
                NavigationStack {
                    RiderScheduleView()
                }
            case .settings:
                NavigationStack {
                    SettingsView()
                }
            case nil:
                ContentUnavailableView("Select a section", systemImage: "list.bullet.rectangle")
            }
        }
        .task {
            RosterStore(modelContext: modelContext).normalizeExternalIDs()
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Rider.self, Team.self], inMemory: true)
}
