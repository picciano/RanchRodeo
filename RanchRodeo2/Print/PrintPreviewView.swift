import SwiftUI
import PDFKit

struct PrintPreviewView: View {
    let teams: [Team]

    @AppStorage("showRiderDetails") private var showRiderDetails = true
    @Environment(\.dismiss) private var dismiss

    @State private var pdfDocument: PDFDocument?
    @State private var pdfFileURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Toggle("Show rider details", isOn: $showRiderDetails)
                    .padding()
                    .background(.bar)
                Group {
                    if let doc = pdfDocument {
                        PDFKitView(document: doc)
                    } else {
                        ProgressView("Rendering…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle("Print Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let url = pdfFileURL {
                        ShareLink(item: url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task(id: showRiderDetails) {
                await render()
            }
        }
    }

    private func render() async {
        guard let data = PDFRenderer.renderPDF(teams: teams, showRiderDetails: showRiderDetails) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("RanchRodeoTeams.pdf")
        try? data.write(to: url, options: .atomic)
        pdfDocument = PDFDocument(data: data)
        pdfFileURL = url
    }
}
