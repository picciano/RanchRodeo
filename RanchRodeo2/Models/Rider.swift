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

    var teams: [Team] = []

    var children: [Rider] = []

    @Relationship(inverse: \Rider.children)
    var parents: [Rider] = []

    @Relationship(deleteRule: .cascade, inverse: \Payout.rider)
    var payouts: [Payout] = []

    init(
        externalID: UUID = UUID(),
        firstName: String = "",
        lastName: String = "",
        isChild: Bool = false,
        isParent: Bool = false,
        isWaiverSigned: Bool = false,
        numberOfRides: Int = 2
    ) {
        self.externalID = externalID
        self.firstName = firstName
        self.lastName = lastName
        self.isChild = isChild
        self.isParent = isParent
        self.isWaiverSigned = isWaiverSigned
        self.numberOfRides = numberOfRides
    }
}
