import Foundation

extension Team {
    var hasChildRider: Bool {
        riders.contains { $0.isChild }
    }

    var allRidersHaveSignedWaiver: Bool {
        riders.allSatisfy { $0.isWaiverSigned }
    }

    var hasRiderWithExtraRides: Bool {
        riders.contains { $0.hasRequestedExtraRides }
    }
}
