import SwiftData
import SwiftUI

struct TrackersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tracker.createdAt, order: .reverse) private var trackers: [Tracker]
    @Query private var dayEntries: [DayEntry]

    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DisclaimerBanner(compact: true)

                    if trackers.isEmpty {
                        ContentUnavailableView(
                            "No trackers",
                            systemImage: "chart.bar.doc.horizontal",
                            description: Text("Create a tracker for tax residency, Schengen, or custom limits.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(trackers) { tracker in
                            NavigationLink {
                                TrackerDetailView(tracker: tracker)
                            } label: {
                                let stats = DayCountingService.stats(for: tracker, entries: dayEntries)
                                TrackerProgressCard(tracker: tracker, stats: stats)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    StaydayoGlassButton("Add tracker", systemImage: "plus") {
                        showAdd = true
                    }

                    DisclaimerFooter()
                }
                .padding(20)
            }
            .staydayoScreenBackground()
            .navigationTitle("Trackers")
            .sheet(isPresented: $showAdd) {
                AddTrackerView()
            }
        }
    }
}

struct AddTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var template: TrackerTemplate = TrackerTemplate.all[0]
    @State private var customTitle = ""
    @State private var maxDays = 183
    @State private var selectedCountries: Set<String> = ["ES"]
    @State private var periodKind: TrackerPeriodKind = .calendarYear
    @State private var rollingWindow = 180
    @State private var calendarYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationStack {
            Form {
                Section("What are you tracking?") {
                    Picker("Template", selection: $template) {
                        ForEach(TrackerTemplate.all) { t in
                            Text(t.title).tag(t)
                        }
                    }
                    .onChange(of: template) { _, newValue in
                        applyTemplate(newValue)
                    }

                    if template.id == "custom" {
                        TextField("Tracker name", text: $customTitle)
                    }
                }

                Section("Limit") {
                    Stepper("Max days: \(maxDays)", value: $maxDays, in: 1...366)
                    Picker("Period", selection: $periodKind) {
                        ForEach(TrackerPeriodKind.allCases, id: \.self) { kind in
                            Text(kind.label).tag(kind)
                        }
                    }
                    if periodKind == .calendarYear {
                        Stepper("Year: \(calendarYear)", value: $calendarYear, in: 2020...2040)
                    }
                    if periodKind == .customRolling {
                        Stepper("Window: \(rollingWindow) days", value: $rollingWindow, in: 30...365)
                    }
                }

                Section("Countries") {
                    ForEach(CountryCatalog.popular, id: \.code) { country in
                        Toggle("\(country.flag) \(country.name)", isOn: Binding(
                            get: { selectedCountries.contains(country.code) },
                            set: { on in
                                if on { selectedCountries.insert(country.code) }
                                else { selectedCountries.remove(country.code) }
                            }
                        ))
                    }
                }

                Section("Default alerts") {
                    Text("You can customise alerts after saving.")
                        .font(.caption)
                        .foregroundStyle(StaydayoTheme.inkMuted)
                }

                DisclaimerBanner(compact: true)
            }
            .navigationTitle("Add tracker")
            .onAppear { applyTemplate(template) }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTracker()
                        dismiss()
                    }
                }
            }
        }
    }

    private func applyTemplate(_ t: TrackerTemplate) {
        maxDays = t.maxDays
        periodKind = t.periodKind
        if t.id == "custom" {
            selectedCountries = []
        } else {
            selectedCountries = Set(t.countryCodes)
        }
    }

    private func saveTracker() {
        let title = template.id == "custom"
            ? (customTitle.isEmpty ? "Custom tracker" : customTitle)
            : template.title
        let tracker = Tracker(
            title: title,
            templateID: template.id == "custom" ? nil : template.id,
            maxDays: maxDays,
            periodKind: periodKind,
            countryCodes: Array(selectedCountries),
            calendarYear: periodKind == .calendarYear ? calendarYear : nil,
            rollingWindowDays: rollingWindow
        )
        for alert in template.defaultAlerts {
            let rule = AlertRule(
                daysRemainingThreshold: alert.days,
                label: alert.label,
                detail: alert.detail,
                frequency: alert.days == 14 ? .daily : .once,
                isEnabled: alert.days <= 14
            )
            rule.tracker = tracker
            tracker.alertRules.append(rule)
        }
        modelContext.insert(tracker)
        try? modelContext.save()
    }
}

struct TrackerDetailView: View {
    @Bindable var tracker: Tracker
    @Query private var dayEntries: [DayEntry]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let stats = DayCountingService.stats(for: tracker, entries: dayEntries)
                TrackerProgressCard(tracker: tracker, stats: stats)

                NavigationLink {
                    TrackerAlertsView(tracker: tracker)
                } label: {
                    Label("Alert settings", systemImage: "bell.badge")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .staydayoGlassCard()
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Countries")
                        .font(.headline)
                    Text(tracker.countryCodes.map { "\(CountryCatalog.flag(for: $0)) \(CountryCatalog.name(for: $0))" }.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(StaydayoTheme.inkMuted)
                }
                .padding()
                .staydayoGlassCard()

                DisclaimerBanner()
            }
            .padding(20)
        }
        .staydayoScreenBackground()
        .navigationTitle(tracker.title)
    }
}
