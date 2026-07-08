import SwiftUI

struct PayoutsPrintPreviewView: View {
    let riders: [Rider]

    var body: some View {
        PDFPreviewView(
            title: "Print Preview",
            fileName: "RanchRodeoPayouts.pdf",
            renderID: 0,
            render: { PDFRenderer.renderPayoutsPDF(riders: riders) }
        ) {
            EmptyView()
        }
    }
}
