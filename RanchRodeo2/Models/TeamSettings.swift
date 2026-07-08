import Foundation

/// The kind of event being run, chosen in Settings. Standard events use a fixed
/// team size (3 or 4); round robin uses the fixed `RoundRobinDesign` (28 riders,
/// 63 teams of 4 split into groups A/B/C).
enum EventFormat: String, CaseIterable, Identifiable {
    case threePerson = "3"
    case fourPerson = "4"
    case roundRobin = "RR"

    var id: String { rawValue }

    /// Short label for the segmented picker.
    var pickerLabel: String { rawValue }

    /// Riders per team. Round robin teams are always four.
    var teamSize: Int { self == .threePerson ? 3 : 4 }

    var isRoundRobin: Bool { self == .roundRobin }
}

/// App-wide team configuration backed by UserDefaults, shared with the event
/// picker through `@AppStorage("eventFormat")`. Read this from non-View contexts —
/// the model's warnings, the team generator, and the print layouts — where
/// `@AppStorage` isn't available.
enum TeamSettings {
    static let eventFormatKey = "eventFormat"
    static let defaultFormat: EventFormat = .fourPerson

    static var eventFormat: EventFormat {
        guard let raw = UserDefaults.standard.string(forKey: eventFormatKey),
              let format = EventFormat(rawValue: raw) else { return defaultFormat }
        return format
    }

    /// Riders per team for the current event format.
    static var teamSize: Int { eventFormat.teamSize }
}
