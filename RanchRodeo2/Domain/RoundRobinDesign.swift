import Foundation

/// The fixed combinatorial design behind the round-robin event: a resolvable
/// 2-(28,4,1) design (the maximum "social golfer" schedule for 28 players in
/// groups of 4 over 9 rounds). It guarantees every rider is teamed with every
/// other rider exactly once across their 9 teams.
///
/// The 63 teams are split into three labeled groups (A/B/C) of 21 teams each,
/// with every rider appearing on exactly 3 teams per group. `slots` are indices
/// 0..<28 into a roster; `RoundRobinGenerator` maps them onto actual riders.
///
/// This table is verified by `RoundRobinDesignTests` (every pair exactly once,
/// 9 teams per rider, 21 teams and 3 appearances per rider in each group). Do
/// not hand-edit it — regenerate and re-verify if it ever needs to change.
enum RoundRobinDesign {
    static let riderCount = 28
    static let ridesPerRider = 9
    static let teamSize = 4
    static let teamCount = 63
    static let teamsPerGroup = 21

    enum Group: String, CaseIterable, Identifiable {
        case a = "A", b = "B", c = "C"
        var id: String { rawValue }
        var label: String { "Group \(rawValue)" }
    }

    struct DesignTeam {
        let group: Group
        let slots: [Int]
    }

    static let teams: [DesignTeam] = [
        DesignTeam(group: .a, slots: [0, 8, 14, 17]),
        DesignTeam(group: .a, slots: [1, 9, 20, 23]),
        DesignTeam(group: .a, slots: [2, 4, 15, 16]),
        DesignTeam(group: .a, slots: [3, 5, 21, 22]),
        DesignTeam(group: .a, slots: [6, 11, 13, 18]),
        DesignTeam(group: .a, slots: [7, 10, 12, 19]),
        DesignTeam(group: .a, slots: [24, 25, 26, 27]),
        DesignTeam(group: .a, slots: [0, 13, 21, 26]),
        DesignTeam(group: .a, slots: [1, 6, 19, 22]),
        DesignTeam(group: .a, slots: [2, 5, 10, 25]),
        DesignTeam(group: .a, slots: [3, 9, 15, 17]),
        DesignTeam(group: .a, slots: [4, 8, 12, 18]),
        DesignTeam(group: .a, slots: [7, 14, 23, 24]),
        DesignTeam(group: .a, slots: [11, 16, 20, 27]),
        DesignTeam(group: .a, slots: [0, 6, 12, 16]),
        DesignTeam(group: .a, slots: [1, 15, 18, 24]),
        DesignTeam(group: .a, slots: [2, 8, 21, 23]),
        DesignTeam(group: .a, slots: [3, 4, 10, 27]),
        DesignTeam(group: .a, slots: [5, 9, 13, 19]),
        DesignTeam(group: .a, slots: [7, 17, 20, 26]),
        DesignTeam(group: .a, slots: [11, 14, 22, 25]),
        DesignTeam(group: .b, slots: [0, 1, 2, 3]),
        DesignTeam(group: .b, slots: [4, 17, 19, 24]),
        DesignTeam(group: .b, slots: [5, 12, 23, 26]),
        DesignTeam(group: .b, slots: [6, 10, 14, 20]),
        DesignTeam(group: .b, slots: [7, 11, 15, 21]),
        DesignTeam(group: .b, slots: [8, 13, 22, 27]),
        DesignTeam(group: .b, slots: [9, 16, 18, 25]),
        DesignTeam(group: .b, slots: [0, 15, 19, 25]),
        DesignTeam(group: .b, slots: [1, 12, 21, 27]),
        DesignTeam(group: .b, slots: [2, 13, 20, 24]),
        DesignTeam(group: .b, slots: [3, 14, 18, 26]),
        DesignTeam(group: .b, slots: [4, 5, 6, 7]),
        DesignTeam(group: .b, slots: [8, 9, 10, 11]),
        DesignTeam(group: .b, slots: [16, 17, 22, 23]),
        DesignTeam(group: .b, slots: [0, 5, 11, 24]),
        DesignTeam(group: .b, slots: [1, 10, 13, 17]),
        DesignTeam(group: .b, slots: [2, 7, 18, 22]),
        DesignTeam(group: .b, slots: [3, 12, 20, 25]),
        DesignTeam(group: .b, slots: [4, 9, 14, 21]),
        DesignTeam(group: .b, slots: [6, 15, 23, 27]),
        DesignTeam(group: .b, slots: [8, 16, 19, 26]),
        DesignTeam(group: .c, slots: [0, 10, 18, 23]),
        DesignTeam(group: .c, slots: [1, 4, 11, 26]),
        DesignTeam(group: .c, slots: [2, 14, 19, 27]),
        DesignTeam(group: .c, slots: [3, 7, 13, 16]),
        DesignTeam(group: .c, slots: [5, 8, 15, 20]),
        DesignTeam(group: .c, slots: [6, 17, 21, 25]),
        DesignTeam(group: .c, slots: [9, 12, 22, 24]),
        DesignTeam(group: .c, slots: [0, 7, 9, 27]),
        DesignTeam(group: .c, slots: [1, 5, 14, 16]),
        DesignTeam(group: .c, slots: [2, 11, 12, 17]),
        DesignTeam(group: .c, slots: [3, 6, 8, 24]),
        DesignTeam(group: .c, slots: [4, 13, 23, 25]),
        DesignTeam(group: .c, slots: [10, 15, 22, 26]),
        DesignTeam(group: .c, slots: [18, 19, 20, 21]),
        DesignTeam(group: .c, slots: [0, 4, 20, 22]),
        DesignTeam(group: .c, slots: [1, 7, 8, 25]),
        DesignTeam(group: .c, slots: [2, 6, 9, 26]),
        DesignTeam(group: .c, slots: [3, 11, 19, 23]),
        DesignTeam(group: .c, slots: [5, 17, 18, 27]),
        DesignTeam(group: .c, slots: [10, 16, 21, 24]),
        DesignTeam(group: .c, slots: [12, 13, 14, 15]),
    ]
}
