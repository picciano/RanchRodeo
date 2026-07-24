import SwiftUI

/// Builds the header, per-rider rows, and grand-total footer for the round-robin
/// payouts printout (one row per rider with the three group amounts A/B/C and a
/// total). Assembled into pages by `PaginatedPrintDocument`.
enum RoundRobinPayoutPrintLayout {
    struct Entry {
        let name: String
        let waiverSigned: Bool
        let groupA: Int
        let groupB: Int
        let groupC: Int
        var total: Int { groupA + groupB + groupC }
    }

    private static let nameWidth: CGFloat = 180
    private static let amountWidth: CGFloat = 90

    static func header() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Payouts by Group")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            headerRow
            Divider()
        }
    }

    static func row(_ entry: Entry) -> some View {
        HStack(spacing: 0) {
            Text(entry.name)
                .frame(width: nameWidth, alignment: .leading)
                .foregroundStyle(entry.waiverSigned ? Color.black : Color.red)
                .lineLimit(1)
            amountCell(entry.groupA)
            amountCell(entry.groupB)
            amountCell(entry.groupC)
            Text(entry.total, format: .currency(code: "USD").precision(.fractionLength(0)))
                .frame(width: amountWidth, alignment: .trailing)
                .bold()
                .monospacedDigit()
        }
        .font(.system(size: 11))
        .foregroundStyle(.black)
        .padding(.vertical, 1)
    }

    static func footer(grandTotal: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().padding(.bottom, 6)
            HStack(spacing: 0) {
                Text("Grand Total")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text(grandTotal, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 12, weight: .bold))
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Pieces

    private static var headerRow: some View {
        HStack(spacing: 0) {
            Text("Name").bold().frame(width: nameWidth, alignment: .leading)
            Text("Group A").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Group B").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Group C").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Total").bold().frame(width: amountWidth, alignment: .trailing)
        }
        .font(.system(size: 11))
        .foregroundStyle(.black)
    }

    @ViewBuilder
    private static func amountCell(_ value: Int) -> some View {
        if value > 0 {
            Text(value, format: .currency(code: "USD").precision(.fractionLength(0)))
                .frame(width: amountWidth, alignment: .trailing)
                .monospacedDigit()
        } else {
            Color.clear.frame(width: amountWidth, height: 1)
        }
    }
}
