import Foundation
import UserNotifications

enum NotificationScheduler {
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func rescheduleAll(trackers: [Tracker], entries: [DayEntry]) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for tracker in trackers {
            let stats = DayCountingService.stats(for: tracker, entries: entries)
            for rule in tracker.alertRules where rule.isEnabled {
                scheduleIfNeeded(tracker: tracker, rule: rule, stats: stats)
            }
        }
    }

    private static func scheduleIfNeeded(tracker: Tracker, rule: AlertRule, stats: TrackerStats) {
        let daysLeft = stats.daysLeft
        guard daysLeft <= rule.daysRemainingThreshold else { return }

        let content = UNMutableNotificationContent()
        content.title = "Staydayo"
        if rule.daysRemainingThreshold == 0 {
            content.body = "You've reached the limit on \(tracker.title). Used \(stats.usedDays) of \(stats.maxDays) days."
        } else {
            content.body =
                "\(daysLeft) days left on \(tracker.title). You have used \(stats.usedDays) of \(stats.maxDays) days."
        }
        content.sound = .default

        let identifier = "\(tracker.id.uuidString)-\(rule.id.uuidString)"

        switch rule.frequency {
        case .once:
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        case .daily:
            var date = DateComponents()
            date.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        case .weekly:
            var date = DateComponents()
            date.weekday = 2
            date.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
