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

/// The five payout event categories, used to drive pickers and to write a value into
/// the matching column on a `Payout` record.
enum PayoutCategory: String, CaseIterable, Identifiable {
    case trailer, sorting, branding, penning, avg

    var id: String { rawValue }

    var label: String {
        switch self {
        case .trailer: "Trailer"
        case .sorting: "Sorting"
        case .branding: "Branding"
        case .penning: "Penning"
        case .avg: "Avg"
        }
    }

    var keyPath: ReferenceWritableKeyPath<Payout, Int> {
        switch self {
        case .trailer: \Payout.trailer
        case .sorting: \Payout.sorting
        case .branding: \Payout.branding
        case .penning: \Payout.penning
        case .avg: \Payout.avg
        }
    }
}
