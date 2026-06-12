import Foundation

final class GeneratorRider {
    let id: UUID
    let firstName: String
    let isWaiverSigned: Bool
    let numberOfRides: Int

    var teams: [GeneratorTeam] = []

    init(
        id: UUID = UUID(),
        firstName: String,
        isWaiverSigned: Bool = true,
        numberOfRides: Int = 2
    ) {
        self.id = id
        self.firstName = firstName
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

    var hasRiderWithExtraRides: Bool { riders.contains { $0.hasRequestedExtraRides } }
    var allRidersHaveSignedWaiver: Bool { riders.allSatisfy { $0.isWaiverSigned } }
}
