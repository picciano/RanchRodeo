import Foundation

extension Team {
    var allRidersHaveSignedWaiver: Bool {
        riders.allSatisfy { $0.isWaiverSigned }
    }

    var hasRiderWithExtraRides: Bool {
        riders.contains { $0.hasRequestedExtraRides }
    }
}
