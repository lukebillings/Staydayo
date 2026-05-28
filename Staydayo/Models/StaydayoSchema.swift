import Foundation
import SwiftData

// MARK: - Enums

enum TrackerPeriodKind: String, Codable, CaseIterable {
    case calendarYear = "calendar_year"
    case rolling180 = "rolling_180"
    case customRolling = "custom_rolling"

    var label: String {
        switch self {
        case .calendarYear: "Calendar year"
        case .rolling180: "Rolling 180 days (simplified Schengen)"
        case .customRolling: "Custom rolling window"
        }
    }
}

enum AlertFrequency: String, Codable, CaseIterable {
    case once = "once"
    case daily = "daily"
    case weekly = "weekly"

    var label: String {
        switch self {
        case .once: "Once when crossed"
        case .daily: "Daily until acknowledged"
        case .weekly: "Weekly digest"
        }
    }
}

enum VaultCategory: String, Codable, CaseIterable {
    case passport
    case visa
    case residencePermit
    case boardingPass
    case hotelBooking
    case other

    var label: String {
        switch self {
        case .passport: "Passport"
        case .visa: "Visa"
        case .residencePermit: "Residence permit"
        case .boardingPass: "Boarding pass"
        case .hotelBooking: "Hotel booking"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .passport: "person.text.rectangle"
        case .visa: "doc.text"
        case .residencePermit: "building.columns"
        case .boardingPass: "airplane.departure"
        case .hotelBooking: "bed.double"
        case .other: "folder"
        }
    }
}

// MARK: - Models

@Model
final class Tracker {
    var id: UUID
    var title: String
    var templateID: String?
    var maxDays: Int
    var periodKindRaw: String
    var countryCodes: [String]
    var calendarYear: Int?
    var rollingWindowDays: Int
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \AlertRule.tracker)
    var alertRules: [AlertRule]

    var periodKind: TrackerPeriodKind {
        get { TrackerPeriodKind(rawValue: periodKindRaw) ?? .calendarYear }
        set { periodKindRaw = newValue.rawValue }
    }

    init(
        title: String,
        templateID: String? = nil,
        maxDays: Int,
        periodKind: TrackerPeriodKind,
        countryCodes: [String],
        calendarYear: Int? = nil,
        rollingWindowDays: Int = 180
    ) {
        self.id = UUID()
        self.title = title
        self.templateID = templateID
        self.maxDays = maxDays
        self.periodKindRaw = periodKind.rawValue
        self.countryCodes = countryCodes
        self.calendarYear = calendarYear
        self.rollingWindowDays = rollingWindowDays
        self.createdAt = Date()
        self.alertRules = []
    }
}

@Model
final class DayEntry {
    var id: UUID
    var countryCode: String
    /// Start of calendar day in user's current calendar/time zone.
    var dayStart: Date
    var isConfirmed: Bool
    var sourceRaw: String
    var notes: String?

    init(countryCode: String, dayStart: Date, isConfirmed: Bool = true, source: String = "manual", notes: String? = nil) {
        self.id = UUID()
        self.countryCode = countryCode
        self.dayStart = dayStart
        self.isConfirmed = isConfirmed
        self.sourceRaw = source
        self.notes = notes
    }
}

@Model
final class TripSegment {
    var id: UUID
    var countryCode: String
    var startDay: Date
    var endDay: Date
    var isConfirmed: Bool
    var notes: String?

    init(countryCode: String, startDay: Date, endDay: Date, isConfirmed: Bool = false, notes: String? = nil) {
        self.id = UUID()
        self.countryCode = countryCode
        self.startDay = startDay
        self.endDay = endDay
        self.isConfirmed = isConfirmed
        self.notes = notes
    }
}

@Model
final class ActivePresence {
    var id: UUID
    var countryCode: String
    var arrivedAt: Date
    var leftAt: Date?

    var isActive: Bool { leftAt == nil }

    init(countryCode: String, arrivedAt: Date = Date()) {
        self.id = UUID()
        self.countryCode = countryCode
        self.arrivedAt = arrivedAt
        self.leftAt = nil
    }
}

@Model
final class AlertRule {
    var id: UUID
    var daysRemainingThreshold: Int
    var label: String
    var detail: String
    var frequencyRaw: String
    var isEnabled: Bool
    var isCustom: Bool
    var tracker: Tracker?

    var frequency: AlertFrequency {
        get { AlertFrequency(rawValue: frequencyRaw) ?? .once }
        set { frequencyRaw = newValue.rawValue }
    }

    init(
        daysRemainingThreshold: Int,
        label: String,
        detail: String,
        frequency: AlertFrequency = .once,
        isEnabled: Bool = false,
        isCustom: Bool = false
    ) {
        self.id = UUID()
        self.daysRemainingThreshold = daysRemainingThreshold
        self.label = label
        self.detail = detail
        self.frequencyRaw = frequency.rawValue
        self.isEnabled = isEnabled
        self.isCustom = isCustom
    }
}

@Model
final class VaultDocument {
    var id: UUID
    var title: String
    var categoryRaw: String
    var expiryDate: Date?
    var storedFileName: String
    var addedAt: Date

    var category: VaultCategory {
        get { VaultCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(title: String, category: VaultCategory, storedFileName: String, expiryDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.categoryRaw = category.rawValue
        self.storedFileName = storedFileName
        self.expiryDate = expiryDate
        self.addedAt = Date()
    }
}

enum StaydayoModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            Tracker.self,
            DayEntry.self,
            TripSegment.self,
            ActivePresence.self,
            AlertRule.self,
            VaultDocument.self,
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let local = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                return try ModelContainer(for: schema, configurations: [local])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()
}
