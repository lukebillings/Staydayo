import SwiftUI

/// Warm coral palette aligned with `AccentColor` in Assets.xcassets.
enum StaydayoTheme {
    static let coral = Color(red: 0.722, green: 0.549, blue: 0.357)
    static let coralDark = Color(red: 0.58, green: 0.38, blue: 0.22)
    static let coralLight = Color(red: 0.96, green: 0.91, blue: 0.84)
    static let sand = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let ink = Color(red: 0.14, green: 0.11, blue: 0.09)
    static let inkMuted = Color(red: 0.42, green: 0.36, blue: 0.32)
    static let success = Color(red: 0.22, green: 0.58, blue: 0.42)

    static let paywallGradient = LinearGradient(
        colors: [sand, coralLight.opacity(0.85), sand],
        startPoint: .top,
        endPoint: .bottom
    )

    static let ctaGradient = LinearGradient(
        colors: [coral, coralDark],
        startPoint: .leading,
        endPoint: .trailing
    )
}
