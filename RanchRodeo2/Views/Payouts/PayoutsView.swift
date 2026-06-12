import SwiftUI
import SwiftData

struct PayoutsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Rider.firstName), SortDescriptor(\Rider.lastName)])
    private var riders: [Rider]

    @Query private var teams: [Team]

    @State private var showPrintPreview = false

    var body: some View {
        Group {
            if teams.isEmpty {
                ContentUnavailableView(
                    "No Teams Yet",
                    systemImage: "dollarsign.circle",
                    description: Text("Generate teams in the Teams tab before recording payouts.")
                )
            } else {
                tableContent
            }
        }
        .navigationTitle("Payouts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showPrintPreview = true
                } label: {
                    Label("Print", systemImage: "printer")
                }
                .disabled(riders.isEmpty || teams.isEmpty)
            }
        }
        .sheet(isPresented: $showPrintPreview) {
            PayoutsPrintPreviewView(riders: riders)
        }
        .task { ensureAllPayoutsExist() }
    }

    private var tableContent: some View {
        ScrollView([.horizontal, .vertical]) {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                headerRow
                Divider().gridCellColumns(8)
                ForEach(riders) { rider in
                    ForEach(Array(sortedTeams(of: rider).enumerated()), id: \.element.id) { index, team in
                        if let payout = payout(for: rider, team: team) {
                            PayoutGridRow(
                                payout: payout,
                                teamNumber: team.number,
                                riderName: index == 0 ? rider.displayName : nil,
                                waiverSigned: rider.isWaiverSigned
                            )
                        }
                    }
                    riderTotalRow(for: rider)
                    Divider().gridCellColumns(8)
                }
                grandTotalRow
            }
            .padding()
        }
    }

    private var headerRow: some View {
        GridRow {
            Text("Name").bold()
            Text("Team #").bold()
            Text("Trailer").bold()
            Text("Sorting").bold()
            Text("Branding").bold()
            Text("Penning").bold()
            Text("Avg").bold()
            Text("Total").bold()
        }
    }

    private func riderTotalRow(for rider: Rider) -> some View {
        GridRow {
            Text("")
            Text("")
            Text("")
            Text("")
            Text("")
            Text("")
            Text("Total:")
                .italic()
                .foregroundStyle(.secondary)
            Text(riderTotal(rider), format: .currency(code: "USD").precision(.fractionLength(0)))
                .bold()
        }
    }

    private var grandTotalRow: some View {
        GridRow {
            Text("Grand Total")
                .bold()
                .font(.title3)
            Text("")
            Text("")
            Text("")
            Text("")
            Text("")
            Text("")
            Text(grandTotal, format: .currency(code: "USD").precision(.fractionLength(0)))
                .bold()
                .font(.title3)
        }
    }

    private func sortedTeams(of rider: Rider) -> [Team] {
        rider.teams.sorted { $0.number < $1.number }
    }

    private func payout(for rider: Rider, team: Team) -> Payout? {
        rider.payouts.first { $0.team === team }
    }

    private func riderTotal(_ rider: Rider) -> Int {
        rider.payouts.reduce(0) { $0 + $1.total }
    }

    private var grandTotal: Int {
        riders.reduce(0) { $0 + riderTotal($1) }
    }

    private func ensureAllPayoutsExist() {
        var didCreate = false
        for rider in riders {
            for team in rider.teams {
                if !rider.payouts.contains(where: { $0.team === team }) {
                    let payout = Payout(rider: rider, team: team)
                    modelContext.insert(payout)
                    didCreate = true
                }
            }
        }
        if didCreate {
            try? modelContext.save()
        }
    }
}

private struct PayoutGridRow: View {
    @Bindable var payout: Payout
    let teamNumber: Int
    let riderName: String?
    let waiverSigned: Bool

    var body: some View {
        GridRow {
            if let riderName {
                Text(riderName)
                    .foregroundStyle(waiverSigned ? Color.primary : Color.red)
            } else {
                Text("")
            }
            Text("\(teamNumber)")
                .foregroundStyle(.secondary)
            AmountCell(value: $payout.trailer)
            AmountCell(value: $payout.sorting)
            AmountCell(value: $payout.branding)
            AmountCell(value: $payout.penning)
            AmountCell(value: $payout.avg)
            Text("")
        }
    }
}

private struct AmountCell: View {
    @Binding var value: Int
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("0", value: $value, format: .currency(code: "USD").precision(.fractionLength(0)))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .textFieldStyle(.roundedBorder)
            .frame(width: 90)
            .focused($isFocused)
            .onChange(of: isFocused) { _, focused in
                guard focused else { return }
                // Small delay so the field has fully become first responder before we ask it to select.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.selectAll),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
    }
}

#Preview {
    NavigationStack {
        PayoutsView()
    }
    .modelContainer(for: [Rider.self, Team.self, Payout.self], inMemory: true)
}
