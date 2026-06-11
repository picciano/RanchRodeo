import Testing
import SwiftUI
import UIKit
@testable import RanchRodeo2

@MainActor
struct AppIconRendererTests {

    /// Renders the AppIconArtwork view at 1024×1024 for both appearances and writes the
    /// PNGs directly into the AppIcon.appiconset folder, replacing the existing files.
    /// Run this test manually from Xcode after tweaking the artwork — the test source
    /// file's location is used to locate the project root, so it works regardless of
    /// where the simulator places the test bundle.
    @Test func regenerateAppIconPNGs() throws {
        let outputs: [(name: String, appearance: AppIconArtwork.Appearance)] = [
            ("5053d964-6132-43e2-a109-3acedcb99c9b.png", .standard),
            ("663385c0-0d1b-422c-98a2-4a04056fedf6.png", .dark)
        ]

        let testFile = URL(fileURLWithPath: #filePath)
        let projectRoot = testFile
            .deletingLastPathComponent() // RanchRodeo2Tests/
            .deletingLastPathComponent() // project root
        let appIconDir = projectRoot
            .appendingPathComponent("RanchRodeo2/Assets.xcassets/AppIcon.appiconset")

        for output in outputs {
            let artwork = AppIconArtwork(appearance: output.appearance)
                .frame(width: 1024, height: 1024)
            let renderer = ImageRenderer(content: artwork)
            renderer.scale = 1.0
            renderer.proposedSize = ProposedViewSize(width: 1024, height: 1024)

            guard let image = renderer.uiImage else {
                Issue.record("ImageRenderer returned nil for \(output.name)")
                continue
            }
            guard let data = image.pngData() else {
                Issue.record("pngData() returned nil for \(output.name)")
                continue
            }

            let url = appIconDir.appendingPathComponent(output.name)
            try data.write(to: url, options: .atomic)
        }
    }
}
