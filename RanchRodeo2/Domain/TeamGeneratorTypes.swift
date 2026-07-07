import Foundation

final class GeneratorRider {
    let id: UUID
    let firstName: String
    let isChild: Bool
    let isParent: Bool
    let isWaiverSigned: Bool
    let numberOfRides: Int
    let preferredTeamNumber: Int?

    var teams: [GeneratorTeam] = []
    var parents: [GeneratorRider] = []

    init(
        id: UUID = UUID(),
        firstName: String,
        isChild: Bool = false,
        isParent: Bool = false,
        isWaiverSigned: Bool = true,
        numberOfRides: Int = 2,
        preferredTeamNumber: Int? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.isChild = isChild
        self.isParent = isParent
        self.isWaiverSigned = isWaiverSigned
        self.numberOfRides = numberOfRides
        self.preferredTeamNumber = preferredTeamNumber
    }

    var hasRequestedExtraRides: Bool { numberOfRides > 2 }

    func hasTeam(within delta: Int, ofTeamNumber teamNumber: Int) -> Bool {
        for team in teams where abs(team.number - teamNumber) < delta {
            return true
        }
        return false
    }
}

final class GeneratorTeam {
    let number: Int
    var riders: [GeneratorRider] = []
    var warnings: [String] = []

    init(number: Int) {
        self.number = number
    }

    var hasChildRider: Bool { riders.contains { $0.isChild } }
    var hasRiderWithExtraRides: Bool { riders.contains { $0.hasRequestedExtraRides } }
    var allRidersHaveSignedWaiver: Bool { riders.allSatisfy { $0.isWaiverSigned } }
}
