import Testing
@testable import RanchRodeo2

struct TeamGeneratorTests {

    @discardableResult
    private func addRider(
        to riders: inout [GeneratorRider],
        firstName: String,
        isChild: Bool = false,
        isParent: Bool = false,
        isWaiverSigned: Bool = true,
        numberOfRides: Int = 2
    ) -> GeneratorRider {
        let rider = GeneratorRider(
            firstName: firstName,
            isChild: isChild,
            isParent: isParent,
            isWaiverSigned: isWaiverSigned,
            numberOfRides: numberOfRides
        )
        riders.append(rider)
        return rider
    }

    // MARK: - Team count

    @Test func generatesExpectedNumberOfTeamsForSimpleRoster() {
        var riders: [GeneratorRider] = []
        for i in 0..<8 {
            addRider(to: &riders, firstName: "R\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)
        #expect(teams.count == 4)
    }

    @Test func teamCountRespectsMaxRidesPerRider() {
        var riders: [GeneratorRider] = []
        addRider(to: &riders, firstName: "A", numberOfRides: 5)
        addRider(to: &riders, firstName: "B", numberOfRides: 2)
        addRider(to: &riders, firstName: "C", numberOfRides: 2)
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)
        #expect(teams.count == 5)
    }

    @Test func teamNumbersAreSequentialStartingAtOne() {
        var riders: [GeneratorRider] = []
        for i in 0..<8 {
            addRider(to: &riders, firstName: "R\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)
        #expect(teams.map(\.number) == [1, 2, 3, 4])
    }

    // MARK: - Ride quotas

    @Test func eachRiderReceivesRequestedNumberOfRides() {
        var riders: [GeneratorRider] = []
        for i in 0..<8 {
            addRider(to: &riders, firstName: "R\(i)", numberOfRides: 2)
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        _ = generator.generate(riders: riders)
        for rider in riders {
            #expect(rider.teams.count == rider.numberOfRides, "\(rider.firstName) should have \(rider.numberOfRides) rides")
        }
    }

    @Test func ridersAreNotAssignedToSameTeamTwice() {
        var riders: [GeneratorRider] = []
        for i in 0..<8 {
            addRider(to: &riders, firstName: "R\(i)", numberOfRides: 2)
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)
        for team in teams {
            let ids = team.riders.map(\.id)
            #expect(Set(ids).count == ids.count, "Team \(team.number) has duplicate riders")
        }
    }

    // MARK: - Child / parent binding

    @Test func childRiderTriggersParentBindingOnSameTeam() {
        var riders: [GeneratorRider] = []
        let parent = addRider(to: &riders, firstName: "Parent", isParent: true, numberOfRides: 2)
        let child = addRider(to: &riders, firstName: "Child", isChild: true, numberOfRides: 2)
        child.parents = [parent]
        for i in 0..<6 {
            addRider(to: &riders, firstName: "Filler\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        _ = generator.generate(riders: riders)
        for team in child.teams {
            #expect(team.riders.contains { $0 === parent }, "Parent should ride on team \(team.number) with child")
        }
    }

    @Test func parentRidesWithEveryChildEvenWhenItExceedsParentQuota() {
        var riders: [GeneratorRider] = []
        let parent = addRider(to: &riders, firstName: "Parent", isParent: true, numberOfRides: 2)
        let firstChild = addRider(to: &riders, firstName: "Alice", isChild: true, numberOfRides: 2)
        let secondChild = addRider(to: &riders, firstName: "Bob", isChild: true, numberOfRides: 2)
        firstChild.parents = [parent]
        secondChild.parents = [parent]
        for i in 0..<5 {
            addRider(to: &riders, firstName: "Filler\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        _ = generator.generate(riders: riders)

        for team in firstChild.teams {
            #expect(team.riders.contains { $0 === parent },
                    "Parent should be on team \(team.number) with Alice")
        }
        for team in secondChild.teams {
            #expect(team.riders.contains { $0 === parent },
                    "Parent should be on team \(team.number) with Bob")
        }
    }

    // MARK: - Balanced fill

    @Test func twelveRidersWithTwoRidesEachFillSixTeamsCompletely() {
        var riders: [GeneratorRider] = []
        for i in 0..<12 {
            addRider(to: &riders, firstName: "R\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)

        #expect(teams.count == 6)
        for team in teams {
            #expect(team.riders.count == 4, "Team \(team.number) has \(team.riders.count) riders, expected 4")
        }
        for rider in riders {
            #expect(rider.teams.count == 2, "\(rider.firstName) got \(rider.teams.count) rides, expected 2")
        }
    }

    // MARK: - Configurable team size

    @Test func threePersonTeamsFillCompletely() {
        var riders: [GeneratorRider] = []
        for i in 0..<9 {
            addRider(to: &riders, firstName: "R\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1), teamSize: 3)
        let teams = generator.generate(riders: riders)

        // 9 riders × 2 rides = 18 ride-slots ÷ 3 per team = 6 teams.
        #expect(teams.count == 6)
        for team in teams {
            #expect(team.riders.count == 3, "Team \(team.number) has \(team.riders.count) riders, expected 3")
        }
        for rider in riders {
            #expect(rider.teams.count == 2, "\(rider.firstName) got \(rider.teams.count) rides, expected 2")
        }
    }

    @Test func threePersonTeamNeverExceedsThreeRiders() {
        var riders: [GeneratorRider] = []
        for i in 0..<11 {
            addRider(to: &riders, firstName: "R\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 7), teamSize: 3)
        let teams = generator.generate(riders: riders)
        for team in teams {
            #expect(team.riders.count <= 3, "Team \(team.number) exceeded the team size of 3")
        }
    }

    @Test func warningUsesConfiguredTeamSize() {
        var riders: [GeneratorRider] = []
        for i in 0..<2 {
            addRider(to: &riders, firstName: "R\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1), teamSize: 3)
        let teams = generator.generate(riders: riders)
        let allWarnings = teams.flatMap(\.warnings)
        #expect(allWarnings.contains("Team should have 3 riders."))
    }

    // MARK: - Warning generation

    @Test func warningIsCreatedForTeamWithFewerThanFourRiders() {
        var riders: [GeneratorRider] = []
        for i in 0..<3 {
            addRider(to: &riders, firstName: "R\(i)")
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)
        let allWarnings = teams.flatMap(\.warnings)
        #expect(allWarnings.contains("Team should have 4 riders."))
    }

    @Test func warningIsCreatedForUnsignedWaiver() {
        var riders: [GeneratorRider] = []
        for i in 0..<8 {
            addRider(to: &riders, firstName: "R\(i)", isWaiverSigned: i != 0)
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)
        let allWarnings = teams.flatMap(\.warnings)
        #expect(allWarnings.contains("All riders need to sign waiver."))
    }

    @Test func noWarningsWhenAllRulesSatisfied() {
        var riders: [GeneratorRider] = []
        for i in 0..<8 {
            addRider(to: &riders, firstName: "R\(i)", isWaiverSigned: true)
        }
        var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: 1))
        let teams = generator.generate(riders: riders)
        #expect(teams.allSatisfy { $0.warnings.isEmpty })
    }

    // MARK: - Determinism

    @Test func sameSeedProducesIdenticalAssignments() {
        func snapshot(seed: UInt64) -> [[String]] {
            var riders: [GeneratorRider] = []
            for i in 0..<8 {
                addRider(to: &riders, firstName: "R\(i)")
            }
            var generator = TeamGenerator(rng: SeededRandomNumberGenerator(seed: seed))
            let teams = generator.generate(riders: riders)
            return teams.map { team in
                team.riders.map(\.firstName).sorted()
            }
        }

        let first = snapshot(seed: 12345)
        let second = snapshot(seed: 12345)
        #expect(first == second)
    }
}
