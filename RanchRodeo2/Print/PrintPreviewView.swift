import SwiftUI

struct PrintPreviewView: View {
    let teams: [Team]

    @AppStorage("showRiderDetails") private var showRiderDetails = true

    var body: some View {
        PDFPreviewView(
            title: "Print Preview",
            fileName: "RanchRodeoTeams.pdf",
            renderID: showRiderDetails,
            render: { PDFRenderer.renderPDF(teams: teams, showRiderDetails: showRiderDetails) }
        ) {
            Toggle("Show rider details", isOn: $showRiderDetails)
                .padding()
                .background(.bar)
        }
    }
}
