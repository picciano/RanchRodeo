import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var riders: [Rider]
    @Query private var teams: [Team]

    @AppStorage("showRiderDetails") private var showRiderDetails = true
    @AppStorage("payoutsEnabled") private var payoutsEnabled = false
    @AppStorage("teamSize") private var teamSize = TeamSettings.defaultTeamSize

    @State private var showTeamSizeConfirmation = false
    @State private var proposedTeamSize = TeamSettings.defaultTeamSize

    @State private var exportName: String = ""
    @State private var jsonExportURL: URL?
    @State private var csvExportURL: URL?
    @State private var isShowingImporter = false
    @State private var activeImportKind: ImportKind = .json
    @State private var activeImportMode: ImportMode = .add
    @State private var importMessage: ImportMessage?
    @State private var showJSONLoadDialog = false
    @State private var showCSVLoadDialog = false

    private enum ImportKind {
        case json, csv
        var contentTypes: [UTType] {
            switch self {
            case .json: [.json]
            case .csv: [.commaSeparatedText, .plainText]
            }
        }
    }

    private enum ImportMode {
        case add, replace
    }

    var body: some View {
        Form {
            Section("About") {
                LabeledContent("Riders", value: "\(riders.count)")
                LabeledContent("Total Rides", value: "\(totalRides)")
                LabeledContent("Number of Teams", value: "\(numberOfTeams)")
                LabeledContent("App", value: "Ranch Rodeo 2 v\(appVersion)")
            }

            Section {
                HStack {
                    Text("Riders per team")
                    Spacer()
                    Picker("Riders per team", selection: teamSizeBinding) {
                        Text("3").tag(3)
                        Text("4").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 120)
                }
            } header: {
                Text("Team Size")
            } footer: {
                Text("Choose how many riders make up each team. Changing this clears any generated teams so you can regenerate them.")
            }

            Section {
                TextField("Roster name", text: $exportName, prompt: Text(defaultExportName))
                    .textInputAutocapitalization(.words)
                if let url = jsonExportURL {
                    ShareLink(item: url, preview: SharePreview(currentExportName, icon: Image(systemName: "doc.text"))) {
                        Label("Save Roster", systemImage: "square.and.arrow.up")
                    }
                }
                if let url = csvExportURL {
                    ShareLink(item: url, preview: SharePreview(currentExportName, icon: Image(systemName: "tablecells"))) {
                        Label("Save as Spreadsheet", systemImage: "tablecells")
                    }
                }
            } header: {
                Text("Save Roster")
            } footer: {
                Text("The roster name becomes the filename, so you can keep multiple saved rosters side by side. Use \"Save as Spreadsheet\" to open the file in Excel or Numbers.")
            }
            .disabled(riders.isEmpty)

            Section {
                Button {
                    showJSONLoadDialog = true
                } label: {
                    Label("Load Roster", systemImage: "square.and.arrow.down")
                }
                Button {
                    showCSVLoadDialog = true
                } label: {
                    Label("Load from Spreadsheet", systemImage: "tablecells.badge.ellipsis")
                }
            } header: {
                Text("Load Roster")
            } footer: {
                Text("Add keeps the riders you already have and brings in any new ones. Replace clears the current roster first, then loads the file.")
            }

            Section("Features") {
                Toggle("Show rider details on prints", isOn: $showRiderDetails)
                Toggle("Track payouts", isOn: $payoutsEnabled)
            }
        }
        .navigationTitle("Settings")
        .onAppear { refreshExports() }
        .onChange(of: riders.count) { refreshExports() }
        .onChange(of: exportName) { refreshExports() }
        .fileImporter(
            isPresented: $isShowingImporter,
            allowedContentTypes: activeImportKind.contentTypes
        ) { result in
            switch activeImportKind {
            case .json: handleJSONImport(result)
            case .csv: handleCSVImport(result)
            }
        }
        .alert(item: $importMessage) { message in
            Alert(title: Text(message.title), message: Text(message.body), dismissButton: .default(Text("OK")))
        }
        .confirmationDialog(
            "Load Roster",
            isPresented: $showJSONLoadDialog,
            titleVisibility: .visible
        ) {
            Button("Add to current roster") {
                startImport(kind: .json, mode: .add)
            }
            Button("Replace current roster", role: .destructive) {
                startImport(kind: .json, mode: .replace)
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Load from Spreadsheet",
            isPresented: $showCSVLoadDialog,
            titleVisibility: .visible
        ) {
            Button("Add to current roster") {
                startImport(kind: .csv, mode: .add)
            }
            Button("Replace current roster", role: .destructive) {
                startImport(kind: .csv, mode: .replace)
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Change team size?",
            isPresented: $showTeamSizeConfirmation,
            titleVisibility: .visible
        ) {
            Button("Change and Clear Teams", role: .destructive) {
                teamSize = proposedTeamSize
                RosterStore(modelContext: modelContext).clearTeams()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Changing team size removes the current \(teams.count) team\(teams.count == 1 ? "" : "s"). You'll need to regenerate them.")
        }
    }

    // MARK: - Team size

    /// Intercepts picker changes: when teams already exist, defer the change behind a
    /// confirmation instead of writing the new value immediately. Because the getter keeps
    /// returning the current `teamSize`, the segmented control visually snaps back until the
    /// user confirms — no manual revert needed.
    private var teamSizeBinding: Binding<Int> {
        Binding(
            get: { teamSize },
            set: { newValue in
                guard newValue != teamSize else { return }
                if teams.isEmpty {
                    teamSize = newValue
                } else {
                    proposedTeamSize = newValue
                    showTeamSizeConfirmation = true
                }
            }
        )
    }

    // MARK: - Roster totals

    /// Sum of every rider's requested rides.
    private var totalRides: Int {
        riders.reduce(0) { $0 + $1.numberOfRides }
    }

    /// Teams needed to seat all rides at the configured team size, rounded up.
    private var numberOfTeams: Int {
        guard teamSize > 0 else { return 0 }
        return Int((Double(totalRides) / Double(teamSize)).rounded(.up))
    }

    // MARK: - App version

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    // MARK: - Export naming

    private var currentExportName: String {
        let trimmed = exportName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultExportName : trimmed
    }

    private var defaultExportName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "Roster \(formatter.string(from: Date()))"
    }

    private var jsonFilename: String { "\(sanitize(currentExportName)).json" }
    private var csvFilename: String { "\(sanitize(currentExportName)).csv" }

    private func sanitize(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return name.components(separatedBy: invalid).joined(separator: "_")
    }

    // MARK: - Export preparation

    private func refreshExports() {
        guard !riders.isEmpty else {
            jsonExportURL = nil
            csvExportURL = nil
            return
        }
        prepareJSONExport()
        prepareCSVExport()
    }

    private func prepareJSONExport() {
        let doc = RosterDocument.snapshot(of: riders, context: modelContext)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(doc) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(jsonFilename)
        try? data.write(to: url, options: .atomic)
        jsonExportURL = url
    }

    private func prepareCSVExport() {
        let csv = CSVCoder.encode(riders: riders)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(csvFilename)
        try? csv.data(using: .utf8)?.write(to: url, options: .atomic)
        csvExportURL = url
    }

    // MARK: - Import dispatch

    private func startImport(kind: ImportKind, mode: ImportMode) {
        activeImportKind = kind
        activeImportMode = mode
        isShowingImporter = true
    }

    private func summaryMessage(_ summary: RosterDocument.ImportSummary) -> String {
        if summary.skipped == 0 {
            return "\(summary.imported) riders added."
        }
        return "\(summary.imported) added, \(summary.skipped) skipped as duplicates."
    }

    private func handleJSONImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            guard
                let data = try? Data(contentsOf: url),
                let document = try? JSONDecoder().decode(RosterDocument.self, from: data)
            else {
                importMessage = ImportMessage(title: "Import Failed", body: "Could not read the JSON file.")
                return
            }
            if activeImportMode == .replace {
                RosterStore(modelContext: modelContext).clearRoster()
            }
            let summary = document.apply(to: modelContext)
            importMessage = ImportMessage(title: "Imported", body: summaryMessage(summary))
        case .failure(let error):
            importMessage = ImportMessage(title: "Import Failed", body: error.localizedDescription)
        }
    }

    private func handleCSVImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            guard
                let data = try? Data(contentsOf: url),
                let text = String(data: data, encoding: .utf8)
            else {
                importMessage = ImportMessage(title: "Import Failed", body: "Could not read the CSV file.")
                return
            }
            if activeImportMode == .replace {
                RosterStore(modelContext: modelContext).clearRoster()
            }
            let exports = CSVCoder.decode(text)
            let doc = RosterDocument(riders: exports)
            let summary = doc.apply(to: modelContext)
            importMessage = ImportMessage(title: "Imported", body: summaryMessage(summary))
        case .failure(let error):
            importMessage = ImportMessage(title: "Import Failed", body: error.localizedDescription)
        }
    }

    private struct ImportMessage: Identifiable {
        let id = UUID()
        let title: String
        let body: String
    }
}
