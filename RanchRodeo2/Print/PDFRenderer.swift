import SwiftUI
import CoreGraphics

@MainActor
enum PDFRenderer {
    static func renderPDF(teams: [Team], showRiderDetails: Bool) -> Data? {
        let pageSize = TeamPrintLayout.pageSize
        let pages = teams.chunked(into: TeamPrintLayout.teamsPerPage)

        let mutableData = NSMutableData()
        guard let consumer = CGDataConsumer(data: mutableData) else { return nil }
        var pageBox = CGRect(origin: .zero, size: pageSize)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &pageBox, nil) else { return nil }

        for pageTeams in pages {
            let pageView = TeamPrintLayout(teams: pageTeams, showRiderDetails: showRiderDetails)
            let renderer = ImageRenderer(content: pageView)
            renderer.proposedSize = ProposedViewSize(width: pageSize.width, height: pageSize.height)

            pdfContext.beginPDFPage(nil)
            renderer.render { _, drawInto in
                drawInto(pdfContext)
            }
            pdfContext.endPDFPage()
        }
        pdfContext.closePDF()
        return mutableData as Data
    }

    static func renderRiderSchedulePDF(riders: [Rider]) -> Data? {
        let pageSize = RiderSchedulePrintLayout.pageSize
        let pages = riders.chunked(into: RiderSchedulePrintLayout.ridersPerPage)

        let mutableData = NSMutableData()
        guard let consumer = CGDataConsumer(data: mutableData) else { return nil }
        var pageBox = CGRect(origin: .zero, size: pageSize)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &pageBox, nil) else { return nil }

        for pageRiders in pages {
            let pageView = RiderSchedulePrintLayout(riders: pageRiders)
            let renderer = ImageRenderer(content: pageView)
            renderer.proposedSize = ProposedViewSize(width: pageSize.width, height: pageSize.height)

            pdfContext.beginPDFPage(nil)
            renderer.render { _, drawInto in
                drawInto(pdfContext)
            }
            pdfContext.endPDFPage()
        }
        pdfContext.closePDF()
        return mutableData as Data
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
