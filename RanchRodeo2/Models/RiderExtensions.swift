import Foundation

extension Collection where Element == Rider {
    /// Only the riders that count toward teams, totals, and printouts.
    var activeRiders: [Rider] {
        filter { $0.isActive }
    }

    /// Sum of every active rider's requested rides. Inactive riders are excluded.
    var totalRides: Int {
        activeRiders.reduce(0) { $0 + $1.numberOfRides }
    }

    /// Teams needed to seat all active rides at the given size, rounded up to the next
    /// whole team. Zero when there are no rides. Mirrors the generator's capacity calc.
    func numberOfTeams(teamSize: Int = TeamSettings.teamSize) -> Int {
        guard teamSize > 0 else { return 0 }
        return Int((Double(totalRides) / Double(teamSize)).rounded(.up))
    }
}

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
