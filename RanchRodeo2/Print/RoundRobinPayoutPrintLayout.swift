import SwiftUI

/// Print layout for round-robin payouts: one row per rider with the three group
/// amounts (A/B/C) and a total, plus a grand total on the last page.
struct RoundRobinPayoutPrintLayout: View {
    static let pageSize = CGSize(width: 612, height: 792) // US Letter @ 72 DPI
    static let ridersPerPage = 30

    struct Entry {
        let name: String
        let waiverSigned: Bool
        let groupA: Int
        let groupB: Int
        let groupC: Int
        var total: Int { groupA + groupB + groupC }
    }

    let entries: [Entry]
    let isLastPage: Bool
    let grandTotal: Int

    private static let nameWidth: CGFloat = 180
    private static let amountWidth: CGFloat = 90

    var body: some View {
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

            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                row(entry)
            }

            if isLastPage {
                Divider().padding(.top, 6)
                HStack(spacing: 0) {
                    Text("Grand Total")
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                    Text(grandTotal, format: .currency(code: "USD").precision(.fractionLength(0)))
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                }
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: Self.pageSize.width, height: Self.pageSize.height, alignment: .topLeading)
        .background(Color.white)
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Name").bold().frame(width: Self.nameWidth, alignment: .leading)
            Text("Group A").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Group B").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Group C").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Total").bold().frame(width: Self.amountWidth, alignment: .trailing)
        }
        .font(.system(size: 11))
        .foregroundStyle(.black)
    }

    private func row(_ entry: Entry) -> some View {
        HStack(spacing: 0) {
            Text(entry.name)
                .frame(width: Self.nameWidth, alignment: .leading)
                .foregroundStyle(entry.waiverSigned ? Color.black : Color.red)
                .lineLimit(1)
            amountCell(entry.groupA)
            amountCell(entry.groupB)
            amountCell(entry.groupC)
            Text(entry.total, format: .currency(code: "USD").precision(.fractionLength(0)))
                .frame(width: Self.amountWidth, alignment: .trailing)
                .bold()
                .monospacedDigit()
        }
        .font(.system(size: 11))
        .foregroundStyle(.black)
        .padding(.vertical, 1)
    }

    @ViewBuilder
    private func amountCell(_ value: Int) -> some View {
        if value > 0 {
            Text(value, format: .currency(code: "USD").precision(.fractionLength(0)))
                .frame(width: Self.amountWidth, alignment: .trailing)
                .monospacedDigit()
        } else {
            Color.clear.frame(width: Self.amountWidth, height: 1)
        }
    }
}
