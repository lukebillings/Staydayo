import SwiftUI

/// Navy, gold, and cream palette derived from product reference.
enum StaydayoTheme {
    static let navy = Color(red: 0.09, green: 0.12, blue: 0.22)
    static let navySoft = Color(red: 0.14, green: 0.18, blue: 0.30)
    static let gold = Color(red: 0.72, green: 0.55, blue: 0.36)
    static let goldDark = Color(red: 0.58, green: 0.38, blue: 0.22)
    static let cream = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let creamCard = Color.white.opacity(0.92)
    static let ink = Color(red: 0.12, green: 0.11, blue: 0.10)
    static let inkMuted = Color(red: 0.45, green: 0.42, blue: 0.40)
    static let success = Color(red: 0.22, green: 0.58, blue: 0.42)
    static let warning = Color(red: 0.85, green: 0.55, blue: 0.18)
    static let danger = Color(red: 0.78, green: 0.28, blue: 0.24)

    // Legacy aliases used by paywall
    static let coral = gold
    static let coralDark = goldDark
    static let coralLight = Color(red: 0.94, green: 0.88, blue: 0.78)
    static let sand = cream

    static let screenGradient = LinearGradient(
        colors: [cream, Color(red: 0.95, green: 0.93, blue: 0.88)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let paywallGradient = LinearGradient(
        colors: [cream, coralLight.opacity(0.85), cream],
        startPoint: .top,
        endPoint: .bottom
    )

    static let ctaGradient = LinearGradient(
        colors: [gold, goldDark],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressGold = LinearGradient(
        colors: [gold, goldDark],
        startPoint: .leading,
        endPoint: .trailing
    )
}
