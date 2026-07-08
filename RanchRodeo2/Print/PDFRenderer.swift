import SwiftUI
import CoreGraphics

@MainActor
enum PDFRenderer {
    /// Team sheets. Round-robin teams (tagged with a group) are printed one group
    /// per page-set with a group heading; standard events use a single flat grid.
    static func renderPDF(teams: [Team], showRiderDetails: Bool) -> Data? {
        var pages: [TeamPrintLayout] = []
        if teams.contains(where: { $0.group != nil }) {
            for group in RoundRobinDesign.Group.allCases {
                let groupTeams = teams.filter { $0.group == group.rawValue }
                guard !groupTeams.isEmpty else { continue }
                for chunk in groupTeams.chunked(into: TeamPrintLayout.teamsPerPage) {
                    pages.append(TeamPrintLayout(
                        teams: chunk,
                        showRiderDetails: showRiderDetails,
                        heading: "Round Robin — \(group.label)"
                    ))
                }
            }
        } else {
            for chunk in teams.chunked(into: TeamPrintLayout.teamsPerPage) {
                pages.append(TeamPrintLayout(teams: chunk, showRiderDetails: showRiderDetails))
            }
        }
        return renderDocument(pageSize: TeamPrintLayout.pageSize, pages)
    }

    static func renderPayoutsPDF(riders: [Rider]) -> Data? {
        let chunks = riders.chunked(into: PayoutPrintLayout.ridersPerPage)
        let pageChunks = chunks.isEmpty ? [[]] : chunks
        let grandTotal = riders.flatMap { $0.payouts }.reduce(0) { $0 + $1.total }
        let pages = pageChunks.enumerated().map { index, pageRiders in
            PayoutPrintLayout(riders: pageRiders, isLastPage: index == pageChunks.count - 1, grandTotal: grandTotal)
        }
        return renderDocument(pageSize: PayoutPrintLayout.pageSize, pages)
    }

    /// Round-robin payouts: one row per rider with per-group amounts.
    static func renderRoundRobinPayoutsPDF(riders: [Rider]) -> Data? {
        let entries = riders.map {
            RoundRobinPayoutPrintLayout.Entry(
                name: $0.displayName,
                waiverSigned: $0.isWaiverSigned,
                groupA: $0.groupPayoutA,
                groupB: $0.groupPayoutB,
                groupC: $0.groupPayoutC
            )
        }
        let chunks = entries.chunked(into: RoundRobinPayoutPrintLayout.ridersPerPage)
        let pageChunks = chunks.isEmpty ? [[]] : chunks
        let grandTotal = riders.reduce(0) { $0 + $1.totalGroupPayout }
        let pages = pageChunks.enumerated().map { index, pageEntries in
            RoundRobinPayoutPrintLayout(entries: pageEntries, isLastPage: index == pageChunks.count - 1, grandTotal: grandTotal)
        }
        return renderDocument(pageSize: RoundRobinPayoutPrintLayout.pageSize, pages)
    }

    static func renderPayoutSummaryPDF(
        entries: [PayoutSummaryPrintLayout.Entry],
        showTotal: Int
    ) -> Data? {
        let chunks = entries.chunked(into: PayoutSummaryPrintLayout.entriesPerPage)
        let pageChunks = chunks.isEmpty ? [[]] : chunks
        let pages = pageChunks.enumerated().map { index, pageEntries in
            PayoutSummaryPrintLayout(entries: pageEntries, isLastPage: index == pageChunks.count - 1, showTotal: showTotal)
        }
        return renderDocument(pageSize: PayoutSummaryPrintLayout.pageSize, pages)
    }

    static func renderRiderSchedulePDF(riders: [Rider], isRoundRobin: Bool = false) -> Data? {
        let pages = riders.chunked(into: RiderSchedulePrintLayout.ridersPerPage).map {
            RiderSchedulePrintLayout(riders: $0, isRoundRobin: isRoundRobin)
        }
        return renderDocument(pageSize: RiderSchedulePrintLayout.pageSize, pages)
    }

    // MARK: - Page rendering

    /// Renders a sequence of identically-typed page views into a multi-page PDF.
    private static func renderDocument<Page: View>(pageSize: CGSize, _ pages: [Page]) -> Data? {
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data) else { return nil }
        var pageBox = CGRect(origin: .zero, size: pageSize)
        guard let context = CGContext(consumer: consumer, mediaBox: &pageBox, nil) else { return nil }

        for page in pages {
            let renderer = ImageRenderer(content: page)
            renderer.proposedSize = ProposedViewSize(width: pageSize.width, height: pageSize.height)
            context.beginPDFPage(nil)
            renderer.render { _, drawInto in
                drawInto(context)
            }
            context.endPDFPage()
        }
        context.closePDF()
        return data as Data
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
