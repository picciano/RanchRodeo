import Foundation

enum CSVCoder {
    static let header = "firstName,lastName,isChild,isParent,isWaiverSigned,numberOfRides"

    @MainActor
    static func encode(riders: [Rider]) -> String {
        var lines = [header]
        for rider in riders {
            let fields: [String] = [
                escape(rider.firstName),
                escape(rider.lastName),
                String(rider.isChild),
                String(rider.isParent),
                String(rider.isWaiverSigned),
                String(rider.numberOfRides),
            ]
            lines.append(fields.joined(separator: ","))
        }
        return lines.joined(separator: "\n")
    }

    static func decode(_ text: String) -> [RosterDocument.RiderExport] {
        let lines = text.split(whereSeparator: \.isNewline).map(String.init)
        guard lines.count > 1 else { return [] }
        var results: [RosterDocument.RiderExport] = []
        for line in lines.dropFirst() {
            let fields = parseRow(line)
            guard fields.count >= 6 else { continue }
            results.append(
                RosterDocument.RiderExport(
                    id: UUID(),
                    firstName: fields[0],
                    lastName: fields[1],
                    isChild: Bool(fields[2]) ?? false,
                    isParent: Bool(fields[3]) ?? false,
                    isWaiverSigned: Bool(fields[4]) ?? false,
                    numberOfRides: Int(fields[5]) ?? 2
                )
            )
        }
        return results
    }

    // MARK: - Helpers

    private static func escape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    private static func parseRow(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var i = line.startIndex
        while i < line.endIndex {
            let ch = line[i]
            if inQuotes {
                if ch == "\"" {
                    let next = line.index(after: i)
                    if next < line.endIndex, line[next] == "\"" {
                        current.append("\"")
                        i = next
                    } else {
                        inQuotes = false
                    }
                } else {
                    current.append(ch)
                }
            } else {
                if ch == "," {
                    fields.append(current)
                    current = ""
                } else if ch == "\"" {
                    inQuotes = true
                } else {
                    current.append(ch)
                }
            }
            i = line.index(after: i)
        }
        fields.append(current)
        return fields
    }
}
