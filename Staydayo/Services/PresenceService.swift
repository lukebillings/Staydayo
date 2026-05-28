import Foundation
import SwiftData

enum PresenceService {
    @MainActor
    static func activePresence(in context: ModelContext) -> ActivePresence? {
        let descriptor = FetchDescriptor<ActivePresence>(
            predicate: #Predicate { $0.leftAt == nil },
            sortBy: [SortDescriptor(\.arrivedAt, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }

    @MainActor
    static func arrive(countryCode: String, context: ModelContext, calendar: Calendar = .current) throws {
        if let existing = activePresence(in: context) {
            try leave(presence: existing, context: context, calendar: calendar)
        }
        let presence = ActivePresence(countryCode: countryCode, arrivedAt: Date())
        context.insert(presence)
        try upsertDayEntries(for: presence, context: context, calendar: calendar)
        try context.save()
    }

    @MainActor
    static func leave(presence: ActivePresence? = nil, context: ModelContext, calendar: Calendar = .current) throws {
        guard let active = presence ?? activePresence(in: context) else { return }
        active.leftAt = Date()
        try upsertDayEntries(for: active, context: context, calendar: calendar)
        try context.save()
    }

    @MainActor
    private static func upsertDayEntries(for presence: ActivePresence, context: ModelContext, calendar: Calendar) throws {
        let entries = DayCountingService.materialisePresence(presence, calendar: calendar)
        for entry in entries {
            try upsert(entry, context: context, calendar: calendar)
        }
    }

    @MainActor
    static func upsert(_ entry: DayEntry, context: ModelContext, calendar: Calendar = .current) throws {
        let day = calendar.startOfDay(for: entry.dayStart)
        let code = entry.countryCode
        let descriptor = FetchDescriptor<DayEntry>()
        let existing = try context.fetch(descriptor).first { e in
            calendar.isDate(e.dayStart, inSameDayAs: day) && e.countryCode == code
        }
        if let existing {
            existing.isConfirmed = entry.isConfirmed || existing.isConfirmed
            if let notes = entry.notes { existing.notes = notes }
        } else {
            entry.dayStart = day
            context.insert(entry)
        }
    }

    @MainActor
    static func confirmTrip(_ segment: TripSegment, context: ModelContext, calendar: Calendar = .current) throws {
        segment.isConfirmed = true
        for entry in DayCountingService.materialiseTrip(segment, calendar: calendar) {
            try upsert(entry, context: context, calendar: calendar)
        }
        try context.save()
    }
}
