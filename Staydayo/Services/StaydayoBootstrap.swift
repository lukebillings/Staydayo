import Foundation
import SwiftData

enum StaydayoBootstrap {
    private static let seededKey = "staydayo.didSeedSampleData"

    @MainActor
    static func seedIfNeeded(container: ModelContainer) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        let context = ModelContext(container)

        let spain = Tracker(
            title: "Spain 2026",
            templateID: "spain_tax_2026",
            maxDays: 183,
            periodKind: .calendarYear,
            countryCodes: ["ES"],
            calendarYear: 2026
        )
        for alert in TrackerTemplate.all[0].defaultAlerts {
            let rule = AlertRule(
                daysRemainingThreshold: alert.days,
                label: alert.label,
                detail: alert.detail,
                frequency: alert.days == 14 ? .daily : .once,
                isEnabled: alert.days <= 14
            )
            rule.tracker = spain
            spain.alertRules.append(rule)
        }

        let schengen = Tracker(
            title: "Schengen 90/180",
            templateID: "schengen_90_180",
            maxDays: 90,
            periodKind: .rolling180,
            countryCodes: SchengenCountryCodes.codes
        )
        for alert in TrackerTemplate.all[1].defaultAlerts {
            let rule = AlertRule(
                daysRemainingThreshold: alert.days,
                label: alert.label,
                detail: alert.detail,
                isEnabled: alert.days <= 14
            )
            rule.tracker = schengen
            schengen.alertRules.append(rule)
        }

        context.insert(spain)
        context.insert(schengen)

        let calendar = Calendar.current
        if let start = calendar.date(byAdding: .day, value: -30, to: Date()) {
            for offset in 0..<20 {
                if let day = calendar.date(byAdding: .day, value: offset, to: start) {
                    context.insert(DayEntry(countryCode: "ES", dayStart: day, isConfirmed: true, source: "sample"))
                }
            }
        }

        let trip = TripSegment(
            countryCode: "ES",
            startDay: calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            endDay: Date(),
            isConfirmed: false
        )
        context.insert(trip)

        try? context.save()
        UserDefaults.standard.set(true, forKey: seededKey)
    }
}
