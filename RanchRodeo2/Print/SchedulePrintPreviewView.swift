import SwiftUI
import PDFKit

struct SchedulePrintPreviewView: View {
    let riders: [Rider]

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
            .task {
                await render()
            }
        }
    }

    private func render() async {
        guard let data = PDFRenderer.renderRiderSchedulePDF(riders: riders) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("RanchRodeoSchedule.pdf")
        try? data.write(to: url, options: .atomic)
        pdfDocument = PDFDocument(data: data)
        pdfFileURL = url
    }
}
