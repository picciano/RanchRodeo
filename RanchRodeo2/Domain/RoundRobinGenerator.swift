import Foundation

/// Assigns riders to the fixed `RoundRobinDesign`. The design's 28 slots are a
/// random permutation of the riders (seeded, so a given RNG is reproducible),
/// which varies who lands on which team between generations while preserving the
/// guaranteed pairing/grouping properties.
struct RoundRobinGenerator<RNG: RandomNumberGenerator> {
    private var rng: RNG

    init(rng: RNG) {
        self.rng = rng
    }

    /// A generated team: its group label and the rider indices (into the caller's
    /// roster array) that make it up.
    struct ResultTeam {
        let group: RoundRobinDesign.Group
        let riderIndices: [Int]
    }

    /// Round robin requires exactly `RoundRobinDesign.riderCount` (28) riders.
    static func isValidRiderCount(_ count: Int) -> Bool {
        count == RoundRobinDesign.riderCount
    }

    /// Produces the 63 grouped teams for `riderCount` riders. `riderCount` must be
    /// exactly 28; callers validate beforehand and surface a message otherwise.
    mutating func generate(riderCount: Int) -> [ResultTeam] {
        precondition(Self.isValidRiderCount(riderCount), "Round robin requires exactly \(RoundRobinDesign.riderCount) riders")
        var slotToRider = Array(0..<riderCount)
        slotToRider.shuffle(using: &rng)
        return RoundRobinDesign.teams.map { team in
            ResultTeam(
                group: team.group,
                riderIndices: team.slots.map { slotToRider[$0] }
            )
        }
    }
}
