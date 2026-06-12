import Foundation

extension Rider {
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var displayName: String {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unnamed" : trimmed
    }

    var hasMeaningfulName: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasRequestedExtraRides: Bool {
        numberOfRides > 2
    }

    func hasTeam(within delta: Int, ofTeamNumber teamNumber: Int) -> Bool {
        for team in teams where abs(team.number - teamNumber) < delta {
            return true
        }
        return false
    }
}
