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
        var isRoper: Bool
        var isNewRider: Bool
        var isWaiverSigned: Bool
        var numberOfRides: Int
        var parentIDs: [UUID]
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
                isRoper: rider.isRoper,
                isNewRider: rider.isNewRider,
                isWaiverSigned: rider.isWaiverSigned,
                numberOfRides: rider.numberOfRides,
                parentIDs: rider.parents.map(\.externalID)
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
                isRoper: export.isRoper,
                isNewRider: export.isNewRider,
                isWaiverSigned: export.isWaiverSigned,
                numberOfRides: export.numberOfRides
            )
            context.insert(rider)
            insertedByID[export.id] = rider
        }
        // Wire parent links — prefer newly imported rider, fall back to pre-existing rider.
        for export in riders {
            guard let rider = insertedByID[export.id] else { continue }
            rider.parents = export.parentIDs.compactMap { id in
                insertedByID[id] ?? existingByID[id]
            }
        }
        try? context.save()
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
