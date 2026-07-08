import Foundation

extension Team {
    var allRidersHaveSignedWaiver: Bool {
        riders.allSatisfy { $0.isWaiverSigned }
    }
}
