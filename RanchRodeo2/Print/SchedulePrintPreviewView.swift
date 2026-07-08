import SwiftUI

struct SchedulePrintPreviewView: View {
    let riders: [Rider]

    var body: some View {
        PDFPreviewView(
            title: "Print Preview",
            fileName: "RanchRodeoSchedule.pdf",
            renderID: 0,
            render: { PDFRenderer.renderRiderSchedulePDF(riders: riders) }
        ) {
            EmptyView()
        }
    }
}
