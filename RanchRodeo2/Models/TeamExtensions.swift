import Foundation

extension Team {
    var hasChildRider: Bool {
        riders.contains { $0.isChild }
    }

    var hasRoper: Bool {
        riders.contains { $0.isRoper }
    }

    var hasNewRider: Bool {
        riders.contains { $0.isNewRider }
    }

    var allRidersHaveSignedWaiver: Bool {
        riders.allSatisfy { $0.isWaiverSigned }
    }

    var hasRiderWithExtraRides: Bool {
        riders.contains { $0.hasRequestedExtraRides }
    }
}
