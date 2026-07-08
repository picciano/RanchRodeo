import SwiftUI
import SwiftData

struct EditTeamView: View {
    @Bindable var team: Team
    @Environment(\.modelContext) private var modelContext

    @AppStorage("payoutsEnabled") private var payoutsEnabled = false

    @Query(sort: [SortDescriptor(\Team.number)])
    private var allTeams: [Team]

    @State private var selectedCategory: PayoutCategory = .trailer
    @State private var amountText: String = ""
    @State private var confirmation: String?
    @State private var confirmationTask: Task<Void, Never>?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Form {
            Section("Riders") {
                if team.riders.isEmpty {
                    Text("No riders assigned.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(team.riders) { rider in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rider.displayName)
                                    .foregroundStyle(rider.isWaiverSigned ? Color.primary : Color.red)
                                let labels = rider.categoryLabels
                                if !labels.isEmpty {
                                    HStack(spacing: 4) {
                                        ForEach(labels, id: \.self) { label in
                                            Text(label)
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.secondary.opacity(0.18), in: Capsule())
                                        }
                                    }
                                }
                            }
                            Spacer()
                            Menu {
                                let others = allTeams.filter { $0 !== team }
                                if others.isEmpty {
                                    Text("No other teams")
                                } else {
                                    ForEach(others) { other in
                                        Button("Move to Team \(other.number)") {
                                            move(rider: rider, to: other)
                                        }
                                    }
                                }
                                Divider()
                                Button("Remove from team", role: .destructive) {
                                    remove(rider: rider)
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.large)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Section("Warnings") {
                WarningsListView(team: team)
            }

            // Round-robin payouts are per group (entered in the Payouts tab), not per team.
            if payoutsEnabled && team.group == nil {
                Section {
                    if horizontalSizeClass == .compact {
                        VStack(spacing: 16) {
                            payoutControls
                            keypad
                        }
                    } else {
                        HStack(alignment: .top, spacing: 24) {
                            payoutControls
                            keypad
                                .frame(maxWidth: 260)
                        }
                    }
                } header: {
                    Text("Add Payouts")
                } footer: {
                    Text("Sets the \(selectedCategory.label) payout for every rider on this team to the amount entered.")
                }
            }
        }
        .navigationTitle("Edit Team \(team.number)")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if let confirmation {
                Label(confirmation, systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(.secondary.opacity(0.2)))
                    .shadow(radius: 4, y: 2)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    /// The whole-dollar value the organizer has entered on the keypad.
    private var enteredAmount: Int { Int(amountText) ?? 0 }

    /// Category picker, running amount, and the apply button — the left column on iPad,
    /// stacked above the keypad on iPhone.
    private var payoutControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Category")
                Spacer()
                Picker("Category", selection: $selectedCategory) {
                    ForEach(PayoutCategory.allCases) { category in
                        Text(category.label).tag(category)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Amount per rider")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(enteredAmount, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.title.weight(.semibold).monospacedDigit())
                    .foregroundStyle(amountText.isEmpty ? .secondary : .primary)
            }

            Button("Add Payout") {
                addPayout()
            }
            .buttonStyle(.borderedProminent)
            .disabled(team.riders.isEmpty || enteredAmount == 0)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// An in-app numeric keypad so amount entry never depends on the system keyboard,
    /// which can't be reliably kept numeric on iPad.
    private var keypad: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow { digitKey(1); digitKey(2); digitKey(3) }
            GridRow { digitKey(4); digitKey(5); digitKey(6) }
            GridRow { digitKey(7); digitKey(8); digitKey(9) }
            GridRow {
                actionKey("Clear", systemImage: "xmark") { amountText = "" }
                    .disabled(amountText.isEmpty)
                digitKey(0)
                actionKey("Delete", systemImage: "delete.left") {
                    if !amountText.isEmpty { amountText.removeLast() }
                }
                .disabled(amountText.isEmpty)
            }
        }
        .padding(.vertical, 4)
    }

    private func digitKey(_ digit: Int) -> some View {
        Button {
            appendDigit(digit)
        } label: {
            Text("\(digit)")
                .font(.title2.monospacedDigit())
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
    }

    private func actionKey(_ label: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(label)
    }

    private func appendDigit(_ digit: Int) {
        // No leading zeros; cap the magnitude so the value stays reasonable.
        guard !(amountText.isEmpty && digit == 0), amountText.count < 7 else { return }
        amountText.append(String(digit))
    }

    private func addPayout() {
        let amount = enteredAmount
        guard amount > 0 else { return }
        let riderCount = team.riders.count
        for rider in team.riders {
            payoutRecord(for: rider)[keyPath: selectedCategory.keyPath] = amount
        }
        persist()
        let formattedAmount = amount.formatted(.currency(code: "USD").precision(.fractionLength(0)))
        showConfirmation("\(selectedCategory.label) set to \(formattedAmount) for \(riderCount) rider\(riderCount == 1 ? "" : "s")")
        amountText = ""
    }

    /// Shows a self-dismissing confirmation toast, replacing any that's still on screen.
    private func showConfirmation(_ message: String) {
        confirmationTask?.cancel()
        withAnimation { confirmation = message }
        confirmationTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            withAnimation { confirmation = nil }
        }
    }

    /// Returns the rider's payout record for this team, creating it on first use.
    private func payoutRecord(for rider: Rider) -> Payout {
        if let existing = rider.payouts.first(where: { $0.team === team }) {
            return existing
        }
        let payout = Payout(rider: rider, team: team)
        modelContext.insert(payout)
        return payout
    }

    private func move(rider: Rider, to destination: Team) {
        team.riders.removeAll { $0 === rider }
        if !destination.riders.contains(where: { $0 === rider }) {
            destination.riders.append(rider)
        }
        persist()
    }

    private func remove(rider: Rider) {
        team.riders.removeAll { $0 === rider }
        persist()
    }

    private func persist() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save team edit: \(error)")
        }
    }
}
