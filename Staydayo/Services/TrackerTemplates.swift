import Foundation

struct TrackerTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let maxDays: Int
    let periodKind: TrackerPeriodKind
    let countryCodes: [String]
    let defaultAlerts: [(days: Int, label: String, detail: String)]

    static let all: [TrackerTemplate] = [
        TrackerTemplate(
            id: "spain_tax_2026",
            title: "Spain Tax Residency 2026",
            subtitle: "183 days in a calendar year",
            maxDays: 183,
            periodKind: .calendarYear,
            countryCodes: ["ES"],
            defaultAlerts: [
                (30, "30 days left", "Early heads-up"),
                (14, "14 days left", "Recommended"),
                (7, "7 days left", "Final reminder"),
                (0, "At limit", "You've reached the limit"),
            ]
        ),
        TrackerTemplate(
            id: "schengen_90_180",
            title: "Schengen 90/180",
            subtitle: "Simplified rolling count",
            maxDays: 90,
            periodKind: .rolling180,
            countryCodes: SchengenCountryCodes.codes,
            defaultAlerts: [
                (30, "30 days left", "Early heads-up"),
                (14, "14 days left", "Recommended"),
                (7, "7 days left", "Final reminder"),
                (0, "At limit", "You've reached the limit"),
            ]
        ),
        TrackerTemplate(
            id: "uk_tax",
            title: "UK Tax Residency",
            subtitle: "183 days in a tax year",
            maxDays: 183,
            periodKind: .calendarYear,
            countryCodes: ["GB"],
            defaultAlerts: [
                (30, "30 days left", "Early heads-up"),
                (14, "14 days left", "Recommended"),
                (0, "At limit", "At limit"),
            ]
        ),
        TrackerTemplate(
            id: "portugal_nhr",
            title: "Portugal NHR Stay",
            subtitle: "Custom limit — adjust as needed",
            maxDays: 183,
            periodKind: .calendarYear,
            countryCodes: ["PT"],
            defaultAlerts: [
                (14, "14 days left", "Recommended"),
                (0, "At limit", "At limit"),
            ]
        ),
        TrackerTemplate(
            id: "custom",
            title: "Custom tracker",
            subtitle: "Choose countries and limits",
            maxDays: 90,
            periodKind: .calendarYear,
            countryCodes: [],
            defaultAlerts: [
                (14, "14 days left", "Recommended"),
                (0, "At limit", "At limit"),
            ]
        ),
    ]
}

enum SchengenCountryCodes {
    /// Schengen area (simplified list for v1).
    static let codes: [String] = [
        "AT", "BE", "HR", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IS", "IT",
        "LV", "LI", "LT", "LU", "MT", "NL", "NO", "PL", "PT", "SK", "SI", "ES", "SE", "CH",
    ]
}

enum CountryCatalog {
    static let popular: [(code: String, name: String, flag: String)] = [
        ("ES", "Spain", "🇪🇸"),
        ("GB", "United Kingdom", "🇬🇧"),
        ("FR", "France", "🇫🇷"),
        ("DE", "Germany", "🇩🇪"),
        ("IT", "Italy", "🇮🇹"),
        ("PT", "Portugal", "🇵🇹"),
        ("US", "United States", "🇺🇸"),
        ("AE", "United Arab Emirates", "🇦🇪"),
        ("TH", "Thailand", "🇹🇭"),
        ("CH", "Switzerland", "🇨🇭"),
        ("NL", "Netherlands", "🇳🇱"),
        ("IE", "Ireland", "🇮🇪"),
    ]

    static func name(for code: String) -> String {
        popular.first { $0.code == code }?.name ?? code
    }

    static func flag(for code: String) -> String {
        popular.first { $0.code == code }?.flag ?? "🏳️"
    }
}
