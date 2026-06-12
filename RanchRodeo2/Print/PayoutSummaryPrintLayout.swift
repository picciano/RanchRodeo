import SwiftUI

struct PayoutSummaryPrintLayout: View {
    static let pageSize = CGSize(width: 612, height: 792) // US Letter @ 72 DPI
    static let entriesPerPage = 36

    struct Entry {
        let name: String
        let waiverSigned: Bool
        let total: Int
    }

    let entries: [Entry]
    let isLastPage: Bool
    let showTotal: Int

    var body: some View {
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

            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
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

            Spacer(minLength: 0)

            if isLastPage {
                Divider().padding(.top, 6)
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
        .padding(24)
        .frame(width: Self.pageSize.width, height: Self.pageSize.height, alignment: .topLeading)
        .background(Color.white)
    }
}
