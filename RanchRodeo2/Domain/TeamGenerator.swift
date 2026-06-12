import Foundation

enum TeamGenerationConstants {
    static let maxRidersPerTeam = 4
    static let minimumWaitBetweenRides = 2
    static let preferredWaitBetweenRides = 4
}

struct TeamGenerator<RNG: RandomNumberGenerator> {
    private var rng: RNG

    init(rng: RNG) {
        self.rng = rng
    }

    @discardableResult
    mutating func generate(riders: [GeneratorRider]) -> [GeneratorTeam] {
        let numberOfTeams = calculatedNumberOfTeams(riders: riders)
        let teams = (1...numberOfTeams).map { GeneratorTeam(number: $0) }

        let childRiders = riders.filter { $0.isChild }
        let extraRideRiders = riders.filter { $0.hasRequestedExtraRides }

        process(riders: childRiders, teams: teams)
        process(riders: extraRideRiders, teams: teams)
        process(riders: riders, teams: teams)

        rebalance(riders: riders, teams: teams)

        determineWarnings(teams: teams)
        return teams
    }

    private mutating func process(riders: [GeneratorRider], teams: [GeneratorTeam]) {
        for rider in riders {
            let parents = rider.parents.sorted { $0.firstName < $1.firstName }

            // A rider's teams.count can exceed numberOfRides — for example, a parent who
            // was attached to multiple children's teams. Guard the range to avoid trapping.
            guard rider.teams.count < rider.numberOfRides else { continue }

            for i in rider.teams.count..<rider.numberOfRides {
                guard let team = findTeam(for: rider, teams: teams) else { continue }
                attach(rider: rider, to: team)

                if rider.isChild && !rider.parents.isEmpty {
                    let parent = parents[i % parents.count]
                    // Parent-child pairing wins over the parent's ride quota — we attach
                    // the parent every time the child lands, even if it pushes the parent
                    // over their requested rides. Only skip a literal duplicate placement.
                    if !team.riders.contains(where: { $0 === parent }) {
                        attach(rider: parent, to: team)
                    }
                }
            }
        }
    }

    private func attach(rider: GeneratorRider, to team: GeneratorTeam) {
        team.riders.append(rider)
        rider.teams.append(team)
    }

    private func detach(rider: GeneratorRider, from team: GeneratorTeam) {
        team.riders.removeAll { $0 === rider }
        rider.teams.removeAll { $0 === team }
    }

    private mutating func findTeam(for rider: GeneratorRider, teams: [GeneratorTeam]) -> GeneratorTeam? {
        var potentialTeams: [GeneratorTeam] = []
        var preferredTeams: [GeneratorTeam] = []
        var bestMatchTeams: [GeneratorTeam] = []

        for team in teams {
            if team.riders.count >= TeamGenerationConstants.maxRidersPerTeam { continue }
            if rider.teams.contains(where: { $0 === team }) { continue }
            potentialTeams.append(team)
        }

        for team in potentialTeams {
            if rider.hasTeam(within: TeamGenerationConstants.minimumWaitBetweenRides, ofTeamNumber: team.number) { continue }
            if rider.isChild && team.hasChildRider { continue }
            preferredTeams.append(team)
        }

        for team in preferredTeams {
            if rider.hasRequestedExtraRides && team.hasRiderWithExtraRides { continue }
            if rider.hasTeam(within: TeamGenerationConstants.preferredWaitBetweenRides, ofTeamNumber: team.number) { continue }
            bestMatchTeams.append(team)
        }

        if !bestMatchTeams.isEmpty {
            return pickLeastFilled(from: bestMatchTeams)
        }
        if !preferredTeams.isEmpty {
            return pickLeastFilled(from: preferredTeams)
        }
        if !potentialTeams.isEmpty {
            return pickLeastFilled(from: potentialTeams)
        }
        return nil
    }

    /// Picks randomly among the least-filled teams in the candidate set, so the algorithm
    /// fills teams evenly rather than packing some to capacity before touching others.
    private mutating func pickLeastFilled(from teams: [GeneratorTeam]) -> GeneratorTeam? {
        guard !teams.isEmpty else { return nil }
        let minCount = teams.map { $0.riders.count }.min() ?? 0
        let leastFilled = teams.filter { $0.riders.count == minCount }
        return leastFilled.randomElement(using: &rng)
    }

    /// Final pass: if any rider is below quota, place them on an under-filled team —
    /// swapping an existing rider out if necessary to make room while keeping full teams full.
    private mutating func rebalance(riders: [GeneratorRider], teams: [GeneratorTeam]) {
        var underServed = riders.filter { $0.teams.count < $0.numberOfRides }

        // First pass: direct placement onto under-filled teams.
        for rider in underServed where rider.teams.count < rider.numberOfRides {
            while rider.teams.count < rider.numberOfRides {
                let candidates = teams.filter { team in
                    team.riders.count < TeamGenerationConstants.maxRidersPerTeam &&
                    !rider.teams.contains(where: { $0 === team })
                }
                guard let team = pickLeastFilled(from: candidates) else { break }
                attach(rider: rider, to: team)
            }
        }

        // Second pass: for remaining short riders, swap a movable rider off a full team
        // onto a team where they have no presence yet, opening a slot for the short rider.
        underServed = riders.filter { $0.teams.count < $0.numberOfRides }
        for shortRider in underServed where shortRider.teams.count < shortRider.numberOfRides {
            while shortRider.teams.count < shortRider.numberOfRides {
                guard let swapPlan = findSwapPlan(for: shortRider, teams: teams) else { break }
                detach(rider: swapPlan.moveRider, from: swapPlan.fromTeam)
                attach(rider: swapPlan.moveRider, to: swapPlan.toTeam)
                attach(rider: shortRider, to: swapPlan.fromTeam)
            }
        }
    }

    private struct SwapPlan {
        let moveRider: GeneratorRider
        let fromTeam: GeneratorTeam
        let toTeam: GeneratorTeam
    }

    private func findSwapPlan(for shortRider: GeneratorRider, teams: [GeneratorTeam]) -> SwapPlan? {
        // We need a team `fromTeam` that's full but doesn't yet contain `shortRider`,
        // containing some rider `X` who could be moved to an under-filled team `toTeam`
        // that does not yet contain X.
        let fullTeams = teams.filter { team in
            team.riders.count >= TeamGenerationConstants.maxRidersPerTeam &&
            !shortRider.teams.contains(where: { $0 === team })
        }
        let underFilled = teams.filter { $0.riders.count < TeamGenerationConstants.maxRidersPerTeam }

        for fromTeam in fullTeams {
            for candidate in fromTeam.riders {
                for toTeam in underFilled where toTeam !== fromTeam {
                    if candidate.teams.contains(where: { $0 === toTeam }) { continue }
                    return SwapPlan(moveRider: candidate, fromTeam: fromTeam, toTeam: toTeam)
                }
            }
        }
        return nil
    }

    private func determineWarnings(teams: [GeneratorTeam]) {
        for team in teams {
            if team.riders.count != 4 {
                team.warnings.append("Team should have four riders.")
            }
            if !team.allRidersHaveSignedWaiver {
                team.warnings.append("All riders need to sign waiver.")
            }
        }
    }

    private func calculatedNumberOfTeams(riders: [GeneratorRider]) -> Int {
        let totalRides = riders.reduce(0) { $0 + $1.numberOfRides }
        let maxPerRider = riders.map(\.numberOfRides).max() ?? 0
        let byCapacity = Int((Double(totalRides) / Double(TeamGenerationConstants.maxRidersPerTeam)).rounded(.up))
        return max(byCapacity, maxPerRider)
    }
}
