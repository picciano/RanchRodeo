import SwiftUI
import PDFKit

struct PayoutSummaryPrintPreviewView: View {
    let entries: [(name: String, waiverSigned: Bool, total: Int)]
    let showTotal: Int

    @Environment(\.dismiss) private var dismiss
    @State private var pdfDocument: PDFDocument?
    @State private var pdfFileURL: URL?

    var body: some View {
        NavigationStack {
            Group {
                if let doc = pdfDocument {
                    PDFKitView(document: doc)
                } else {
                    ProgressView("Rendering…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Payout Summary")
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
        }
        .task { await render() }
    }

    private func render() async {
        let mappedEntries = entries.map {
            PayoutSummaryPrintLayout.Entry(name: $0.name, waiverSigned: $0.waiverSigned, total: $0.total)
        }
        guard let data = PDFRenderer.renderPayoutSummaryPDF(entries: mappedEntries, showTotal: showTotal) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("PayoutSummary.pdf")
        try? data.write(to: url, options: .atomic)
        pdfDocument = PDFDocument(data: data)
        pdfFileURL = url
    }
}
