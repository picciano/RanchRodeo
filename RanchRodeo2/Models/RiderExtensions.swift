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

    /// Short single-letter codes for compact displays (team cards, prints).
    /// Concatenated in stable order — e.g. "CP" for a child of a parent (rare),
    /// "C" for child, "P" for parent.
    var categoryCode: String {
        var code = ""
        if isChild { code.append("C") }
        if isParent { code.append("P") }
        return code
    }

    /// Full-word labels for inline category pills on roster/teams/schedule.
    var categoryLabels: [String] {
        var labels: [String] = []
        if isChild { labels.append("Child") }
        if isParent { labels.append("Parent") }
        return labels
    }
}
