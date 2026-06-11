import SwiftUI

struct AppIconArtwork: View {
    enum Appearance {
        case standard
        case dark
    }

    let appearance: Appearance

    var body: some View {
        ZStack {
            background
            vignette
            silhouette
        }
    }

    @ViewBuilder
    private var background: some View {
        switch appearance {
        case .standard:
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.71, blue: 0.36),
                    Color(red: 0.82, green: 0.48, blue: 0.20)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .dark:
            LinearGradient(
                colors: [
                    Color(red: 0.62, green: 0.40, blue: 0.20),
                    Color(red: 0.34, green: 0.19, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var vignette: some View {
        RadialGradient(
            colors: [Color.clear, Color.black.opacity(0.22)],
            center: .center,
            startRadius: 320,
            endRadius: 720
        )
    }

    private var silhouette: some View {
        Image("AppIconSilhouette")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(silhouetteFill)
            .shadow(color: .black.opacity(0.30), radius: 24, x: 0, y: 14)
            .padding(40)
    }

    private var silhouetteFill: LinearGradient {
        switch appearance {
        case .standard:
            LinearGradient(
                colors: [
                    Color.white,
                    Color(white: 0.86)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .dark:
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.09, blue: 0.03),
                    Color(red: 0.04, green: 0.02, blue: 0.01)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

#Preview("Standard") {
    AppIconArtwork(appearance: .standard)
        .frame(width: 256, height: 256)
}

#Preview("Dark") {
    AppIconArtwork(appearance: .dark)
        .frame(width: 256, height: 256)
}
