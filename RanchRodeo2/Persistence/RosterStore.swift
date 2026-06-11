import Foundation
import SwiftData

@MainActor
@Observable
final class RosterStore {
    private let modelContext: ModelContext
    var needsTeamGeneration: Bool = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetching

    func allRiders() -> [Rider] {
        (try? modelContext.fetch(FetchDescriptor<Rider>())) ?? []
    }

    func allTeams() -> [Team] {
        let descriptor = FetchDescriptor<Team>(sortBy: [SortDescriptor(\.number)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func team(number: Int) -> Team? {
        let descriptor = FetchDescriptor<Team>(predicate: #Predicate { $0.number == number })
        return (try? modelContext.fetch(descriptor))?.first
    }

    func teamsWithMissingRiders() -> [Team] {
        allTeams().filter { $0.riders.count < 4 }
    }

    // MARK: - Mutation

    @discardableResult
    func createRider() -> Rider {
        let rider = Rider()
        modelContext.insert(rider)
        return rider
    }

    func delete(_ object: any PersistentModel) {
        modelContext.delete(object)
    }

    func move(rider: Rider, from source: Team, to destination: Team) {
        source.riders.removeAll { $0 === rider }
        if !destination.riders.contains(where: { $0 === rider }) {
            destination.riders.append(rider)
        }
    }

    func save() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save model context: \(error)")
        }
    }

    /// Removes every rider and team from the store. Used by Clear All and Replace-on-import.
    func clearRoster() {
        for team in allTeams() {
            modelContext.delete(team)
        }
        for rider in allRiders() {
            modelContext.delete(rider)
        }
        save()
    }

    /// Ensures every rider has a distinct `externalID`. Existing riders that were migrated
    /// from a schema without `externalID` all share the same default UUID; this fixes that
    /// so dedup-on-import works.
    func normalizeExternalIDs() {
        let riders = allRiders()
        var seen = Set<UUID>()
        var didChange = false
        for rider in riders {
            if seen.contains(rider.externalID) {
                rider.externalID = UUID()
                didChange = true
            }
            seen.insert(rider.externalID)
        }
        if didChange {
            save()
        }
    }

    // MARK: - Team generation

    func regenerateTeams<RNG: RandomNumberGenerator>(rng: RNG) {
        let riders = allRiders()
        let snapshots = buildSnapshots(from: riders)

        for team in allTeams() {
            modelContext.delete(team)
        }

        var generator = TeamGenerator(rng: rng)
        let resultTeams = generator.generate(riders: Array(snapshots.values))

        let ridersByID = Dictionary(uniqueKeysWithValues: riders.map { ($0.persistentModelID, $0) })
        let snapshotToRider: [ObjectIdentifier: Rider] = Dictionary(
            uniqueKeysWithValues: snapshots.compactMap { id, snap in
                guard let rider = ridersByID[id] else { return nil }
                return (ObjectIdentifier(snap), rider)
            }
        )

        for resultTeam in resultTeams {
            let team = Team(number: resultTeam.number)
            modelContext.insert(team)
            for snapshotRider in resultTeam.riders {
                if let rider = snapshotToRider[ObjectIdentifier(snapshotRider)] {
                    team.riders.append(rider)
                }
            }
        }

        needsTeamGeneration = false
        save()
    }

    private func buildSnapshots(from riders: [Rider]) -> [PersistentIdentifier: GeneratorRider] {
        var map: [PersistentIdentifier: GeneratorRider] = [:]
        for rider in riders {
            map[rider.persistentModelID] = GeneratorRider(
                firstName: rider.firstName,
                isChild: rider.isChild,
                isParent: rider.isParent,
                isRoper: rider.isRoper,
                isNewRider: rider.isNewRider,
                isWaiverSigned: rider.isWaiverSigned,
                numberOfRides: rider.numberOfRides
            )
        }
        for rider in riders {
            guard let snap = map[rider.persistentModelID] else { continue }
            snap.parents = rider.parents.compactMap { map[$0.persistentModelID] }
        }
        return map
    }
}
