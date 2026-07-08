import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .secondarySystemBackground
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

/// Shared chrome for the print previews: renders a PDF, shows it in a `PDFKitView` with a
/// Done/Share toolbar, and re-renders whenever `renderID` changes. An optional `header`
/// hosts extra controls above the preview (e.g. the "Show rider details" toggle).
struct PDFPreviewView<Header: View, ID: Equatable>: View {
    let title: String
    let fileName: String
    let renderID: ID
    let render: @MainActor () -> Data?
    @ViewBuilder let header: () -> Header

    @Environment(\.dismiss) private var dismiss
    @State private var pdfDocument: PDFDocument?
    @State private var pdfFileURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header()
                Group {
                    if let pdfDocument {
                        PDFKitView(document: pdfDocument)
                    } else {
                        ProgressView("Rendering…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let pdfFileURL {
                        ShareLink(item: pdfFileURL) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task(id: renderID) { renderPDF() }
        }
    }

    private func renderPDF() {
        guard let data = render() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: url, options: .atomic)
        pdfDocument = PDFDocument(data: data)
        pdfFileURL = url
    }
}
