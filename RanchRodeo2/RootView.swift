import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage("payoutsEnabled") private var payoutsEnabled = false

    enum Section: String, Hashable, CaseIterable, Identifiable {
        case roster, teams, schedule, payouts, settings
        var id: String { rawValue }
        var label: String {
            switch self {
            case .roster: "Roster"
            case .teams: "Teams"
            case .schedule: "Schedule"
            case .payouts: "Payouts"
            case .settings: "Settings"
            }
        }
        var icon: String {
            switch self {
            case .roster: "person.2"
            case .teams: "square.grid.3x3"
            case .schedule: "calendar"
            case .payouts: "dollarsign.circle"
            case .settings: "gearshape"
            }
        }
    }

    @State private var selection: Section? = .roster

    private var visibleSections: [Section] {
        Section.allCases.filter { section in
            section != .payouts || payoutsEnabled
        }
    }

    var body: some View {
        NavigationSplitView {
            List(visibleSections, selection: $selection) { section in
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
            case .payouts:
                NavigationStack {
                    PayoutsView()
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
        .modelContainer(for: [Rider.self, Team.self, Payout.self], inMemory: true)
}
