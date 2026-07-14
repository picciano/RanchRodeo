import Foundation
import SwiftData

@Model
final class Rider {
    var externalID: UUID = UUID()
    var firstName: String
    var lastName: String
    var isChild: Bool
    var isParent: Bool
    var isWaiverSigned: Bool
    var numberOfRides: Int

    /// Inactive riders stay on the roster (struck through) but are excluded from team
    /// generation, every count, and all printouts. New riders default to active.
    var isActive: Bool = true

    /// A team number the rider asked to be seated on first, before the usual placement
    /// rules run. `nil` means no preference. Ignored at generation time if the number
    /// exceeds the teams actually created or that team is already full.
    var preferredTeamNumber: Int?

    var teams: [Team] = []

    var children: [Rider] = []

    @Relationship(inverse: \Rider.children)
    var parents: [Rider] = []

    @Relationship(deleteRule: .cascade, inverse: \Payout.rider)
    var payouts: [Payout] = []

    /// Round-robin payouts: one whole-dollar amount per group (A/B/C). Unused by
    /// standard events, which record payouts per team via `payouts`.
    var groupPayoutA: Int = 0
    var groupPayoutB: Int = 0
    var groupPayoutC: Int = 0

    init(
        externalID: UUID = UUID(),
        firstName: String = "",
        lastName: String = "",
        isChild: Bool = false,
        isParent: Bool = false,
        isWaiverSigned: Bool = false,
        numberOfRides: Int = 2,
        preferredTeamNumber: Int? = nil,
        isActive: Bool = true
    ) {
        self.externalID = externalID
        self.firstName = firstName
        self.lastName = lastName
        self.isChild = isChild
        self.isParent = isParent
        self.isWaiverSigned = isWaiverSigned
        self.numberOfRides = numberOfRides
        self.preferredTeamNumber = preferredTeamNumber
        self.isActive = isActive
    }
}
