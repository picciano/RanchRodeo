import Foundation
import SwiftData

@Model
final class Rider {
    var externalID: UUID = UUID()
    var firstName: String
    var lastName: String
    var isWaiverSigned: Bool
    var numberOfRides: Int

    var teams: [Team] = []

    init(
        externalID: UUID = UUID(),
        firstName: String = "",
        lastName: String = "",
        isWaiverSigned: Bool = false,
        numberOfRides: Int = 2
    ) {
        self.externalID = externalID
        self.firstName = firstName
        self.lastName = lastName
        self.isWaiverSigned = isWaiverSigned
        self.numberOfRides = numberOfRides
    }
}
