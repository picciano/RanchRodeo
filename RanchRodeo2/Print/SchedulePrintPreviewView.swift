import SwiftUI

struct SchedulePrintPreviewView: View {
    let riders: [Rider]

    @AppStorage("eventFormat") private var eventFormat: EventFormat = TeamSettings.defaultFormat

    var body: some View {
        PDFPreviewView(
            title: "Print Preview",
            fileName: "RanchRodeoSchedule.pdf",
            renderID: 0,
            render: { PDFRenderer.renderRiderSchedulePDF(riders: riders, isRoundRobin: eventFormat.isRoundRobin) }
        ) {
            EmptyView()
        }
    }
}
