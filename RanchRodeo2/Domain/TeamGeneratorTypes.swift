import Foundation

final class GeneratorRider {
    let id: UUID
    let firstName: String
    let isChild: Bool
    let isParent: Bool
    let isRoper: Bool
    let isNewRider: Bool
    let isWaiverSigned: Bool
    let numberOfRides: Int

    var teams: [GeneratorTeam] = []
    var parents: [GeneratorRider] = []

    init(
        id: UUID = UUID(),
        firstName: String,
        isChild: Bool = false,
        isParent: Bool = false,
        isRoper: Bool = false,
        isNewRider: Bool = false,
        isWaiverSigned: Bool = true,
        numberOfRides: Int = 2
    ) {
        self.id = id
        self.firstName = firstName
        self.isChild = isChild
        self.isParent = isParent
        self.isRoper = isRoper
        self.isNewRider = isNewRider
        self.isWaiverSigned = isWaiverSigned
        self.numberOfRides = numberOfRides
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
    var hasRoper: Bool { riders.contains { $0.isRoper } }
    var hasNewRider: Bool { riders.contains { $0.isNewRider } }
    var hasRiderWithExtraRides: Bool { riders.contains { $0.hasRequestedExtraRides } }
    var allRidersHaveSignedWaiver: Bool { riders.allSatisfy { $0.isWaiverSigned } }
}
