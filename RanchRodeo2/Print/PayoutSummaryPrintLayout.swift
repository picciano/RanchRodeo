import SwiftUI

/// Builds the header, per-rider rows, and show-total footer for the payout summary
/// printout. Assembled into pages by `PaginatedPrintDocument`.
enum PayoutSummaryPrintLayout {
    struct Entry {
        let name: String
        let waiverSigned: Bool
        let total: Int
    }

    static func header() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Payout Summary")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("NAME")
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text("TOTAL $")
                    .font(.system(size: 11, weight: .semibold))
            }
            Divider()
        }
    }

    static func row(_ entry: Entry) -> some View {
        HStack {
            Text(entry.name)
                .font(.system(size: 12))
                .foregroundStyle(entry.waiverSigned ? Color.black : Color.red)
                .lineLimit(1)
            Spacer()
            Text(entry.total, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 12))
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    static func footer(showTotal: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().padding(.bottom, 6)
            HStack {
                Text("Show Total")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Text(showTotal, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 13, weight: .bold))
                    .monospacedDigit()
            }
        }
    }
}
