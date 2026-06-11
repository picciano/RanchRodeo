import Foundation
import SwiftData

@Model
final class Team {
    var number: Int

    @Relationship(inverse: \Rider.teams)
    var riders: [Rider] = []

    init(number: Int) {
        self.number = number
    }

    /// Warnings are derived from the team's current state — they update automatically
    /// when a rider's flags change without needing to regenerate teams.
    var warnings: [String] {
        var result: [String] = []
        if riders.count != 4 {
            result.append("Team should have four riders.")
        }
        if !allRidersHaveSignedWaiver {
            result.append("All riders need to sign waiver.")
        }
        return result
    }
}
