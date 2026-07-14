import SwiftUI

struct PayoutsPrintPreviewView: View {
    let riders: [Rider]

    @AppStorage("eventFormat") private var eventFormat: EventFormat = TeamSettings.defaultFormat

    var body: some View {
        PDFPreviewView(
            title: "Print Preview",
            fileName: "RanchRodeoPayouts.pdf",
            renderID: 0,
            render: {
                eventFormat.isRoundRobin
                    ? PDFRenderer.renderRoundRobinPayoutsPDF(riders: riders)
                    : PDFRenderer.renderPayoutsPDF(riders: riders)
            }
        ) {
            EmptyView()
        }
    }
}
