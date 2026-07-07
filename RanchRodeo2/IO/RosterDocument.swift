import Foundation
import SwiftData
import UniformTypeIdentifiers
import CoreTransferable

nonisolated struct RosterDocument: Codable, Sendable {
    var version: Int = 1
    var riders: [RiderExport]

    nonisolated struct RiderExport: Codable, Sendable {
        let id: UUID
        var firstName: String
        var lastName: String
        var isChild: Bool
        var isParent: Bool
        var isWaiverSigned: Bool
        var numberOfRides: Int
        var parentIDs: [UUID]
        var preferredTeamNumber: Int?
        // Optional so rosters saved before this field existed still decode (nil = active).
        var isActive: Bool?

        init(
            id: UUID,
            firstName: String,
            lastName: String,
            isChild: Bool = false,
            isParent: Bool = false,
            isWaiverSigned: Bool,
            numberOfRides: Int,
            parentIDs: [UUID] = [],
            preferredTeamNumber: Int? = nil,
            isActive: Bool? = nil
        ) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.isChild = isChild
            self.isParent = isParent
            self.isWaiverSigned = isWaiverSigned
            self.numberOfRides = numberOfRides
            self.parentIDs = parentIDs
            self.preferredTeamNumber = preferredTeamNumber
            self.isActive = isActive
        }
    }

    nonisolated struct ImportSummary {
        let imported: Int
        let skipped: Int
    }
}

extension RosterDocument {
    @MainActor
    static func snapshot(of riders: [Rider], context: ModelContext) -> RosterDocument {
        // Defensive: assign unique IDs to any riders that share one before serializing.
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
            try? context.save()
        }

        let exports = riders.map { rider in
            RiderExport(
                id: rider.externalID,
                firstName: rider.firstName,
                lastName: rider.lastName,
                isChild: rider.isChild,
                isParent: rider.isParent,
                isWaiverSigned: rider.isWaiverSigned,
                numberOfRides: rider.numberOfRides,
                parentIDs: rider.parents.map { $0.externalID },
                preferredTeamNumber: rider.preferredTeamNumber,
                isActive: rider.isActive
            )
        }
        return RosterDocument(riders: exports)
    }

    @MainActor
    @discardableResult
    func apply(to context: ModelContext) -> ImportSummary {
        let existing = (try? context.fetch(FetchDescriptor<Rider>())) ?? []
        let existingByID: [UUID: Rider] = Dictionary(
            existing.map { ($0.externalID, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        var insertedByID: [UUID: Rider] = [:]
        var skipped = 0
        for export in riders {
            if existingByID[export.id] != nil || insertedByID[export.id] != nil {
                skipped += 1
                continue
            }
            let rider = Rider(
                externalID: export.id,
                firstName: export.firstName,
                lastName: export.lastName,
                isChild: export.isChild,
                isParent: export.isParent,
                isWaiverSigned: export.isWaiverSigned,
                numberOfRides: export.numberOfRides,
                preferredTeamNumber: export.preferredTeamNumber,
                isActive: export.isActive ?? true
            )
            context.insert(rider)
            insertedByID[export.id] = rider
        }

        // Resolve parent links after all riders are inserted, so parents declared
        // later in the file still resolve. Look across both newly-inserted and
        // pre-existing riders by externalID.
        let allByID: [UUID: Rider] = existingByID.merging(insertedByID) { _, new in new }
        for export in riders where !export.parentIDs.isEmpty {
            guard let child = insertedByID[export.id] else { continue }
            for parentID in export.parentIDs {
                guard let parent = allByID[parentID] else { continue }
                if !child.parents.contains(where: { $0 === parent }) {
                    child.parents.append(parent)
                }
            }
        }

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save imported roster: \(error)")
        }
        return ImportSummary(imported: insertedByID.count, skipped: skipped)
    }
}

extension RosterDocument: Transferable {
    nonisolated static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .json) { doc in
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(doc)
        } importing: { data in
            try JSONDecoder().decode(RosterDocument.self, from: data)
        }
        .suggestedFileName("Roster.json")
    }
}
