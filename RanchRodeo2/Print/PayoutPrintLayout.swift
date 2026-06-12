import SwiftUI

struct PayoutPrintLayout: View {
    static let pageSize = CGSize(width: 612, height: 792) // US Letter @ 72 DPI
    static let ridersPerPage = 10

    let riders: [Rider]
    let isLastPage: Bool
    let grandTotal: Int

    private static let nameWidth: CGFloat = 130
    private static let teamWidth: CGFloat = 50
    private static let amountWidth: CGFloat = 60

    var body: some View {
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

            ForEach(riders) { rider in
                riderSection(rider)
                Divider()
            }

            if isLastPage {
                grandTotalRow
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
            Text("Team #").bold().frame(width: Self.teamWidth, alignment: .center)
            Text("Trailer").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Sorting").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Branding").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Penning").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Avg").bold().frame(width: Self.amountWidth, alignment: .trailing)
            Text("Total").bold().frame(width: Self.amountWidth, alignment: .trailing)
        }
        .font(.system(size: 10))
        .foregroundStyle(.black)
    }

    private func riderSection(_ rider: Rider) -> some View {
        let sortedTeams = rider.teams.sorted { $0.number < $1.number }
        return VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(sortedTeams.enumerated()), id: \.element.id) { index, team in
                if let payout = rider.payouts.first(where: { $0.team === team }) {
                    teamRow(
                        rider: rider,
                        team: team,
                        payout: payout,
                        showRiderName: index == 0
                    )
                }
            }
            riderTotalRow(rider)
        }
        .font(.system(size: 10))
        .foregroundStyle(.black)
    }

    private func teamRow(rider: Rider, team: Team, payout: Payout, showRiderName: Bool) -> some View {
        HStack(spacing: 0) {
            if showRiderName {
                Text(rider.displayName)
                    .frame(width: Self.nameWidth, alignment: .leading)
                    .foregroundStyle(rider.isWaiverSigned ? Color.black : Color.red)
            } else {
                Color.clear.frame(width: Self.nameWidth)
            }
            Text("\(team.number)").frame(width: Self.teamWidth, alignment: .center)
            amountCell(payout.trailer)
            amountCell(payout.sorting)
            amountCell(payout.branding)
            amountCell(payout.penning)
            amountCell(payout.avg)
            Color.clear.frame(width: Self.amountWidth)
        }
    }

    private func riderTotalRow(_ rider: Rider) -> some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: Self.nameWidth)
            Color.clear.frame(width: Self.teamWidth)
            Color.clear.frame(width: Self.amountWidth)
            Color.clear.frame(width: Self.amountWidth)
            Color.clear.frame(width: Self.amountWidth)
            Color.clear.frame(width: Self.amountWidth)
            Text("Total:")
                .italic()
                .foregroundStyle(.gray)
                .frame(width: Self.amountWidth, alignment: .trailing)
            Text(riderTotal(rider), format: .currency(code: "USD").precision(.fractionLength(0)))
                .bold()
                .frame(width: Self.amountWidth, alignment: .trailing)
        }
    }

    private var grandTotalRow: some View {
        HStack(spacing: 0) {
            Text("Grand Total").bold().font(.system(size: 12))
            Spacer()
            Text(grandTotal, format: .currency(code: "USD").precision(.fractionLength(0)))
                .bold()
                .font(.system(size: 12))
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func amountCell(_ value: Int) -> some View {
        if value > 0 {
            Text(value, format: .currency(code: "USD").precision(.fractionLength(0)))
                .frame(width: Self.amountWidth, alignment: .trailing)
        } else {
            Color.clear.frame(width: Self.amountWidth, height: 1)
        }
    }

    private func riderTotal(_ rider: Rider) -> Int {
        rider.payouts.reduce(0) { $0 + $1.total }
    }
}
