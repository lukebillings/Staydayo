import SwiftUI

/// Brand palette: main #070A17, accents #38FF30 / #01FFEF, surface #F2F4F7.
enum StaydayoTheme {
    static let navy = Color(red: 7 / 255, green: 10 / 255, blue: 23 / 255)
    static let navySoft = Color(red: 18 / 255, green: 24 / 255, blue: 43 / 255)
    static let gold = Color(red: 56 / 255, green: 1, blue: 48 / 255)
    static let goldDark = Color(red: 40 / 255, green: 0.78, blue: 34 / 255)
    static let cream = Color(red: 242 / 255, green: 244 / 255, blue: 247 / 255)
    static let creamCard = Color.white.opacity(0.92)
    static let ink = navy
    static let inkMuted = Color(red: 90 / 255, green: 97 / 255, blue: 120 / 255)
    static let success = gold
    static let warning = Color(red: 0.85, green: 0.55, blue: 0.18)
    static let danger = Color(red: 0.78, green: 0.28, blue: 0.24)

    static let accentCyan = Color(red: 1 / 255, green: 1, blue: 239 / 255)

    // Legacy aliases used by paywall
    static let coral = gold
    static let coralDark = goldDark
    static let coralLight = Color(red: 230 / 255, green: 1, blue: 252 / 255)
    static let sand = cream

    static let screenGradient = LinearGradient(
        colors: [cream, Color(red: 232 / 255, green: 235 / 255, blue: 240 / 255)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let paywallGradient = LinearGradient(
        colors: [cream, coralLight.opacity(0.85), cream],
        startPoint: .top,
        endPoint: .bottom
    )

    static let ctaGradient = LinearGradient(
        colors: [gold, accentCyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressGold = LinearGradient(
        colors: [gold, accentCyan],
        startPoint: .leading,
        endPoint: .trailing
    )
}
