import SwiftUI

struct PayoutSummaryPrintPreviewView: View {
    let entries: [(name: String, waiverSigned: Bool, total: Int)]
    let showTotal: Int

    var body: some View {
        PDFPreviewView(
            title: "Payout Summary",
            fileName: "PayoutSummary.pdf",
            renderID: 0,
            render: {
                let mappedEntries = entries.map {
                    PayoutSummaryPrintLayout.Entry(name: $0.name, waiverSigned: $0.waiverSigned, total: $0.total)
                }
                return PDFRenderer.renderPayoutSummaryPDF(entries: mappedEntries, showTotal: showTotal)
            }
        ) {
            EmptyView()
        }
    }
}
