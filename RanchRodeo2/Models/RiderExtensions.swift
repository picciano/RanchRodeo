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

    var categoryCode: String {
        var code = ""
        if isChild { code += "C" }
        if isParent { code += "P" }
        if isRoper { code += "R" }
        if isNewRider { code += "N" }
        return code
    }

    var categoryLabels: [String] {
        var labels: [String] = []
        if isChild { labels.append("Child") }
        if isParent { labels.append("Parent") }
        if isRoper { labels.append("Roper") }
        if isNewRider { labels.append("New") }
        return labels
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
