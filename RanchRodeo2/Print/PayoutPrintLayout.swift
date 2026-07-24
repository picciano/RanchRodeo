import SwiftUI

/// Builds the header, per-rider rows, and grand-total footer for the standard
/// payouts printout. Assembled into pages by `PaginatedPrintDocument`.
enum PayoutPrintLayout {
    private static let nameWidth: CGFloat = 130
    private static let teamWidth: CGFloat = 50
    private static let amountWidth: CGFloat = 60

    static func header() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Payouts")
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

    /// One rider's team rows plus a per-rider total, followed by a separator.
    static func riderRow(_ rider: Rider) -> some View {
        let sortedTeams = rider.teams.sorted { $0.number < $1.number }
        return VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(sortedTeams.enumerated()), id: \.element.id) { index, team in
                if let payout = rider.payouts.first(where: { $0.team === team }) {
                    teamRow(rider: rider, team: team, payout: payout, showRiderName: index == 0)
                }
            }
            riderTotalRow(rider)
            Divider()
        }
        .font(.system(size: 10))
        .foregroundStyle(.black)
    }

    static func footer(grandTotal: Int) -> some View {
        HStack(spacing: 0) {
            Text("Grand Total").bold().font(.system(size: 12))
            Spacer()
            Text(grandTotal, format: .currency(code: "USD").precision(.fractionLength(0)))
                .bold()
                .font(.system(size: 12))
        }
    }

    // MARK: - Pieces

    private static var headerRow: some View {
        HStack(spacing: 0) {
            Text("Name").bold().frame(width: nameWidth, alignment: .leading)
            Text("Team #").bold().frame(width: teamWidth, alignment: .center)
            Text("Trailer").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Sorting").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Branding").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Penning").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Avg").bold().frame(width: amountWidth, alignment: .trailing)
            Text("Total").bold().frame(width: amountWidth, alignment: .trailing)
        }
        .font(.system(size: 10))
        .foregroundStyle(.black)
    }

    private static func teamRow(rider: Rider, team: Team, payout: Payout, showRiderName: Bool) -> some View {
        HStack(spacing: 0) {
            if showRiderName {
                Text(rider.displayName)
                    .frame(width: nameWidth, alignment: .leading)
                    .foregroundStyle(rider.isWaiverSigned ? Color.black : Color.red)
            } else {
                Color.clear.frame(width: nameWidth)
            }
            Text("\(team.number)").frame(width: teamWidth, alignment: .center)
            amountCell(payout.trailer)
            amountCell(payout.sorting)
            amountCell(payout.branding)
            amountCell(payout.penning)
            amountCell(payout.avg)
            Color.clear.frame(width: amountWidth)
        }
    }

    private static func riderTotalRow(_ rider: Rider) -> some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: nameWidth)
            Color.clear.frame(width: teamWidth)
            Color.clear.frame(width: amountWidth)
            Color.clear.frame(width: amountWidth)
            Color.clear.frame(width: amountWidth)
            Color.clear.frame(width: amountWidth)
            Text("Total:")
                .italic()
                .foregroundStyle(.gray)
                .frame(width: amountWidth, alignment: .trailing)
            Text(riderTotal(rider), format: .currency(code: "USD").precision(.fractionLength(0)))
                .bold()
                .frame(width: amountWidth, alignment: .trailing)
        }
    }

    @ViewBuilder
    private static func amountCell(_ value: Int) -> some View {
        if value > 0 {
            Text(value, format: .currency(code: "USD").precision(.fractionLength(0)))
                .frame(width: amountWidth, alignment: .trailing)
        } else {
            Color.clear.frame(width: amountWidth, height: 1)
        }
    }

    private static func riderTotal(_ rider: Rider) -> Int {
        rider.payouts.reduce(0) { $0 + $1.total }
    }
}
