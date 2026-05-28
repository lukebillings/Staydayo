import Foundation
import SwiftData

struct TrackerStats {
    let usedDays: Int
    let maxDays: Int
    var daysLeft: Int { max(0, maxDays - usedDays) }
    var progress: Double {
        guard maxDays > 0 else { return 0 }
        return min(1, Double(usedDays) / Double(maxDays))
    }
    let periodDescription: String
}

enum DayCountingService {
    static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func daysBetween(start: Date, end: Date, calendar: Calendar = .current) -> [Date] {
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        guard s <= e else { return [] }
        var days: [Date] = []
        var cursor = s
        while cursor <= e {
            days.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return days
    }

    static func entries(
        for tracker: Tracker,
        entries: [DayEntry],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [DayEntry] {
        let codes = Set(tracker.countryCodes)
        let filtered = entries.filter { codes.contains($0.countryCode) }
        let range = periodRange(for: tracker, referenceDate: referenceDate, calendar: calendar)
        return filtered.filter { entry in
            entry.dayStart >= range.start && entry.dayStart <= range.end
        }
    }

    static func stats(
        for tracker: Tracker,
        entries: [DayEntry],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> TrackerStats {
        let matched = entries(for: tracker, entries: entries, referenceDate: referenceDate, calendar: calendar)
        let uniqueDays = Set(matched.map { calendar.startOfDay(for: $0.dayStart) })
        let used = uniqueDays.count
        let desc = periodDescription(for: tracker, referenceDate: referenceDate, calendar: calendar)
        return TrackerStats(usedDays: used, maxDays: tracker.maxDays, periodDescription: desc)
    }

    static func countryTotals(
        entries: [DayEntry],
        from start: Date,
        to end: Date,
        calendar: Calendar = .current
    ) -> [(code: String, days: Int)] {
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        let filtered = entries.filter { $0.dayStart >= s && $0.dayStart <= e }
        var counts: [String: Set<Date>] = [:]
        for entry in filtered {
            let day = calendar.startOfDay(for: entry.dayStart)
            counts[entry.countryCode, default: []].insert(day)
        }
        return counts.map { ($0.key, $0.value.count) }.sorted { $0.days > $1.days }
    }

    static func periodRange(
        for tracker: Tracker,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> (start: Date, end: Date) {
        let ref = calendar.startOfDay(for: referenceDate)
        switch tracker.periodKind {
        case .calendarYear:
            let year = tracker.calendarYear ?? calendar.component(.year, from: ref)
            var comps = DateComponents(year: year, month: 1, day: 1)
            let start = calendar.date(from: comps) ?? ref
            comps.year = year
            comps.month = 12
            comps.day = 31
            let end = calendar.date(from: comps) ?? ref
            return (start, end)
        case .rolling180:
            let start = calendar.date(byAdding: .day, value: -179, to: ref) ?? ref
            return (start, ref)
        case .customRolling:
            let window = max(1, tracker.rollingWindowDays)
            let start = calendar.date(byAdding: .day, value: -(window - 1), to: ref) ?? ref
            return (start, ref)
        }
    }

    static func periodDescription(
        for tracker: Tracker,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let range = periodRange(for: tracker, referenceDate: referenceDate, calendar: calendar)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateStyle = .medium
        switch tracker.periodKind {
        case .calendarYear:
            return "\(formatter.string(from: range.start)) – \(formatter.string(from: range.end))"
        case .rolling180:
            return "Rolling 180 days (simplified)"
        case .customRolling:
            return "Rolling \(tracker.rollingWindowDays) days"
        }
    }

    /// Materialise trip segment into day entries (both countries allowed same day elsewhere).
    static func materialiseTrip(_ segment: TripSegment, calendar: Calendar = .current) -> [DayEntry] {
        daysBetween(start: segment.startDay, end: segment.endDay, calendar: calendar).map { day in
            DayEntry(
                countryCode: segment.countryCode,
                dayStart: day,
                isConfirmed: segment.isConfirmed,
                source: "trip"
            )
        }
    }

    /// Record presence from arrival through today (or leave date).
    static func materialisePresence(_ presence: ActivePresence, through endDate: Date = Date(), calendar: Calendar = .current) -> [DayEntry] {
        let end = presence.leftAt ?? endDate
        return daysBetween(start: presence.arrivedAt, end: end, calendar: calendar).map { day in
            DayEntry(countryCode: presence.countryCode, dayStart: day, isConfirmed: true, source: "presence")
        }
    }
}
