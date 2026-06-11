import SwiftUI

struct WarningsListView: View {
    let team: Team

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if team.warnings.isEmpty {
                Label("No warnings.", systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(team.warnings, id: \.self) { message in
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
