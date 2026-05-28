import Foundation
import PDFKit
import SwiftUI
import UIKit

enum ExportService {
    struct ExportPayload {
        let trackers: [Tracker]
        let entries: [DayEntry]
        let rangeStart: Date
        let rangeEnd: Date
    }

    static func makeCSV(payload: ExportPayload, calendar: Calendar = .current) -> String {
        var lines = ["date,country,country_name,confirmed,source"]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let s = calendar.startOfDay(for: payload.rangeStart)
        let e = calendar.startOfDay(for: payload.rangeEnd)
        let filtered = payload.entries.filter { $0.dayStart >= s && $0.dayStart <= e }
            .sorted { $0.dayStart < $1.dayStart }
        for entry in filtered {
            let date = formatter.string(from: entry.dayStart)
            let name = CountryCatalog.name(for: entry.countryCode)
            lines.append("\(date),\(entry.countryCode),\(name),\(entry.isConfirmed),\(entry.sourceRaw)")
        }
        lines.append("")
        lines.append("# \(StaydayoCopy.disclaimerShort)")
        return lines.joined(separator: "\n")
    }

    static func makePDF(payload: ExportPayload, calendar: Calendar = .current) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateStyle = .medium

        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = 48
            let margin: CGFloat = 48
            let width = pageRect.width - margin * 2

            func draw(_ text: String, font: UIFont, color: UIColor = .black) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let rect = CGRect(x: margin, y: y, width: width, height: 400)
                let h = (text as NSString).boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    attributes: attrs,
                    context: nil
                ).height
                (text as NSString).draw(in: CGRect(x: margin, y: y, width: width, height: h), withAttributes: attrs)
                y += h + 10
            }

            draw("Staydayo — Stay Day Report", font: .boldSystemFont(ofSize: 22))
            draw(
                "Period: \(formatter.string(from: payload.rangeStart)) – \(formatter.string(from: payload.rangeEnd))",
                font: .systemFont(ofSize: 12),
                color: .darkGray
            )
            draw(StaydayoCopy.disclaimer, font: .italicSystemFont(ofSize: 10), color: .gray)

            for tracker in payload.trackers {
                let stats = DayCountingService.stats(
                    for: tracker,
                    entries: payload.entries,
                    referenceDate: payload.rangeEnd,
                    calendar: calendar
                )
                draw(tracker.title, font: .boldSystemFont(ofSize: 16))
                draw(
                    "Used \(stats.usedDays) of \(stats.maxDays) days · \(stats.daysLeft) remaining",
                    font: .systemFont(ofSize: 12)
                )
                draw(stats.periodDescription, font: .systemFont(ofSize: 11), color: .darkGray)
            }

            draw("Country totals", font: .boldSystemFont(ofSize: 14))
            let totals = DayCountingService.countryTotals(
                entries: payload.entries,
                from: payload.rangeStart,
                to: payload.rangeEnd,
                calendar: calendar
            )
            for item in totals {
                draw(
                    "\(CountryCatalog.flag(for: item.code)) \(CountryCatalog.name(for: item.code)): \(item.days) days",
                    font: .systemFont(ofSize: 12)
                )
            }

            draw("Day-by-day log (sample)", font: .boldSystemFont(ofSize: 14))
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "en_GB")
            dayFormatter.dateStyle = .short
            let filtered = payload.entries
                .filter { $0.dayStart >= calendar.startOfDay(for: payload.rangeStart) }
                .sorted { $0.dayStart > $1.dayStart }
                .prefix(60)
            for entry in filtered {
                draw(
                    "\(dayFormatter.string(from: entry.dayStart)) — \(CountryCatalog.name(for: entry.countryCode))",
                    font: .systemFont(ofSize: 10)
                )
                if y > pageRect.height - 60 {
                    context.beginPage()
                    y = 48
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
