import Foundation

/// App-wide team configuration backed by UserDefaults, shared with the "Team Size"
/// setting through `@AppStorage("teamSize")`. Read this from non-View contexts — the
/// model's warnings, the team generator, and the print layouts — where `@AppStorage`
/// isn't available.
enum TeamSettings {
    static let teamSizeKey = "teamSize"
    static let minTeamSize = 3
    static let maxTeamSize = 4
    static let defaultTeamSize = 4

    /// The configured riders-per-team, clamped to the supported range. Falls back to
    /// the default when the key is unset (UserDefaults returns 0 for a missing integer).
    static var teamSize: Int {
        let stored = UserDefaults.standard.integer(forKey: teamSizeKey)
        return (minTeamSize...maxTeamSize).contains(stored) ? stored : defaultTeamSize
    }
}
