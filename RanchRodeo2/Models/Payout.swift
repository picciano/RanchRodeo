import Foundation
import SwiftData

@Model
final class Payout {
    var trailer: Int = 0
    var sorting: Int = 0
    var branding: Int = 0
    var penning: Int = 0
    var avg: Int = 0

    var rider: Rider?
    var team: Team?

    init(rider: Rider, team: Team) {
        self.rider = rider
        self.team = team
    }

    var total: Int { trailer + sorting + branding + penning + avg }
}
