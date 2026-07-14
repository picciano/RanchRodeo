import Foundation
import SwiftData

@Model
final class Team {
    var number: Int

    /// Round-robin group label ("A"/"B"/"C"). `nil` for standard events.
    var group: String?

    @Relationship(inverse: \Rider.teams)
    var riders: [Rider] = []

    @Relationship(deleteRule: .cascade, inverse: \Payout.team)
    var payouts: [Payout] = []

    init(number: Int) {
        self.number = number
    }

    /// Warnings are derived from the team's current state — they update automatically
    /// when a rider's flags change without needing to regenerate teams.
    var warnings: [String] {
        var result: [String] = []
        let expectedSize = TeamSettings.teamSize
        if riders.count != expectedSize {
            result.append("Team should have \(expectedSize) riders.")
        }
        if !allRidersHaveSignedWaiver {
            result.append("All riders need to sign waiver.")
        }
        return result
    }
}
