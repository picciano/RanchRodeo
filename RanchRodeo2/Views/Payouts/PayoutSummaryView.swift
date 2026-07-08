import SwiftUI
import SwiftData

struct PayoutSummaryView: View {
    @Query private var riders: [Rider]

    @AppStorage("eventFormat") private var eventFormat: EventFormat = TeamSettings.defaultFormat

    @State private var showPrintPreview = false

    /// Riders paired with their total payout, sorted by total descending.
    /// Ties are broken alphabetically by display name to keep the order stable.
    /// Round robin totals come from the per-group payouts; standard events sum the
    /// per-team payouts.
    private var sortedEntries: [(rider: Rider, total: Int)] {
        riders.activeRiders
            .map { rider in
                let total = eventFormat.isRoundRobin
                    ? rider.totalGroupPayout
                    : rider.payouts.reduce(0) { $0 + $1.total }
                return (rider, total)
            }
            .sorted { lhs, rhs in
                if lhs.total != rhs.total { return lhs.total > rhs.total }
                return lhs.rider.displayName < rhs.rider.displayName
            }
    }

    private var showTotal: Int {
        sortedEntries.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        Group {
            if sortedEntries.isEmpty {
                ContentUnavailableView(
                    "No Riders",
                    systemImage: "list.number",
                    description: Text("Add riders and record payouts before viewing the summary.")
                )
            } else {
                List {
                    Section {
                        ForEach(sortedEntries, id: \.rider.id) { entry in
                            HStack {
                                Text(entry.rider.displayName)
                                    .foregroundStyle(entry.rider.isWaiverSigned ? Color.primary : Color.red)
                                Spacer()
                                Text(
                                    entry.total,
                                    format: .currency(code: "USD").precision(.fractionLength(0))
                                )
                                .monospacedDigit()
                            }
                        }
                    } header: {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text("Total $")
                        }
                    }

                    Section {
                        HStack {
                            Text("Show Total")
                                .font(.headline)
                            Spacer()
                            Text(
                                showTotal,
                                format: .currency(code: "USD").precision(.fractionLength(0))
                            )
                            .font(.headline)
                            .monospacedDigit()
                        }
                    }
                }
            }
        }
        .navigationTitle("Payout Summary")
        .toolbar {
            if !eventFormat.isRoundRobin {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showPrintPreview = true
                    } label: {
                        Label("Print", systemImage: "printer")
                    }
                    .disabled(sortedEntries.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showPrintPreview) {
            PayoutSummaryPrintPreviewView(
                entries: sortedEntries.map { ($0.rider.displayName, $0.rider.isWaiverSigned, $0.total) },
                showTotal: showTotal
            )
        }
    }
}

#Preview {
    NavigationStack {
        PayoutSummaryView()
    }
    .modelContainer(for: [Rider.self, Team.self, Payout.self], inMemory: true)
}
