import SwiftData
import SwiftUI

struct ExportView: View {
    @Query(sort: \Tracker.createdAt) private var trackers: [Tracker]
    @Query(sort: \DayEntry.dayStart) private var dayEntries: [DayEntry]

    @State private var rangeStart = Calendar.current.date(from: DateComponents(
        year: Calendar.current.component(.year, from: Date()),
        month: 1,
        day: 1
    )) ?? Date()
    @State private var rangeEnd = Date()
    @State private var shareItems: [Any]?
    @State private var showShare = false

    private var payload: ExportService.ExportPayload {
        ExportService.ExportPayload(
            trackers: trackers,
            entries: dayEntries,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )
    }

    private var totals: [(code: String, days: Int)] {
        DayCountingService.countryTotals(entries: dayEntries, from: rangeStart, to: rangeEnd)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DisclaimerBanner(compact: true)

                    exportPreviewCard

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data range")
                            .font(.headline)
                        DatePicker("From", selection: $rangeStart, displayedComponents: .date)
                        DatePicker("To", selection: $rangeEnd, displayedComponents: .date)
                    }
                    .padding(18)
                    .staydayoGlassCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Country totals")
                            .font(.headline)
                        if totals.isEmpty {
                            Text("No days recorded in this range.")
                                .font(.subheadline)
                                .foregroundStyle(StaydayoTheme.inkMuted)
                        } else {
                            ForEach(totals, id: \.code) { item in
                                HStack {
                                    Text("\(CountryCatalog.flag(for: item.code)) \(CountryCatalog.name(for: item.code))")
                                    Spacer()
                                    Text("\(item.days) days")
                                        .fontWeight(.semibold)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    .padding(18)
                    .staydayoGlassCard()

                    HStack(spacing: 12) {
                        exportButton(title: "PDF report", subtitle: "Detailed summary", systemImage: "doc.richtext") {
                            let data = ExportService.makePDF(payload: payload)
                            let url = FileManager.default.temporaryDirectory.appendingPathComponent("Staydayo-report.pdf")
                            try? data.write(to: url)
                            shareItems = [url]
                            showShare = true
                        }
                        exportButton(title: "CSV export", subtitle: "Raw data", systemImage: "tablecells") {
                            let csv = ExportService.makeCSV(payload: payload)
                            let url = FileManager.default.temporaryDirectory.appendingPathComponent("Staydayo-days.csv")
                            try? csv.write(to: url, atomically: true, encoding: .utf8)
                            shareItems = [url]
                            showShare = true
                        }
                    }

                    DisclaimerFooter()
                }
                .padding(20)
            }
            .staydayoScreenBackground()
            .navigationTitle("Export")
            .sheet(isPresented: $showShare) {
                if let shareItems {
                    ShareSheet(items: shareItems)
                }
            }
        }
    }

    private var exportPreviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Export preview")
                .font(.caption.weight(.semibold))
                .foregroundStyle(StaydayoTheme.inkMuted)
            Text(trackers.first?.title ?? "All trackers report")
                .font(.title3.weight(.bold))
            Text("All trackers · \(trackers.count) configured")
                .font(.subheadline)
                .foregroundStyle(StaydayoTheme.inkMuted)
            Text(StaydayoCopy.disclaimerShort)
                .font(.caption2)
                .foregroundStyle(StaydayoTheme.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .staydayoGlassCard()
    }

    private func exportButton(title: String, subtitle: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(StaydayoTheme.goldDark)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(StaydayoTheme.ink)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(StaydayoTheme.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .staydayoGlassCard()
        }
        .buttonStyle(.plain)
    }
}
