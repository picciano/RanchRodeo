import SwiftUI
import SwiftData

@main
struct RanchRodeo2App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Rider.self, Team.self])
    }
}
