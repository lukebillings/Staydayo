import SwiftData
import SwiftUI

struct AlertsHubView: View {
    @Query(sort: \Tracker.createdAt) private var trackers: [Tracker]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DisclaimerBanner(compact: true)

                    if trackers.isEmpty {
                        ContentUnavailableView(
                            "No trackers",
                            systemImage: "bell",
                            description: Text("Add a tracker to configure alerts.")
                        )
                    } else {
                        ForEach(trackers) { tracker in
                            NavigationLink {
                                TrackerAlertsView(tracker: tracker)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(tracker.title)
                                            .font(.headline)
                                            .foregroundStyle(StaydayoTheme.ink)
                                        Text("\(tracker.alertRules.filter(\.isEnabled).count) alerts on")
                                            .font(.caption)
                                            .foregroundStyle(StaydayoTheme.inkMuted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(StaydayoTheme.inkMuted)
                                }
                                .padding(16)
                                .staydayoGlassCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    DisclaimerFooter()
                }
                .padding(20)
            }
            .staydayoScreenBackground()
            .navigationTitle("Alerts")
        }
    }
}

struct TrackerAlertsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var tracker: Tracker
    @Query private var dayEntries: [DayEntry]

    @State private var showAddCustom = false
    @State private var customDays = 21
    @State private var customLabel = "Custom alert"
    @State private var customFrequency: AlertFrequency = .once

    private var stats: TrackerStats {
        DayCountingService.stats(for: tracker, entries: dayEntries)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TrackerProgressCard(tracker: tracker, stats: stats)

                Text("Warning notifications")
                    .font(.headline)

                ForEach(tracker.alertRules.sorted(by: { $0.daysRemainingThreshold > $1.daysRemainingThreshold })) { rule in
                    alertRow(rule)
                }

                StaydayoGlassButton("Add custom threshold", systemImage: "plus") {
                    showAddCustom = true
                }

                notificationPreview
                DisclaimerBanner()
            }
            .padding(20)
        }
        .staydayoScreenBackground()
        .navigationTitle("Alerts")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCustom) {
            NavigationStack {
                Form {
                    Stepper("Days remaining: \(customDays)", value: $customDays, in: 0...120)
                    TextField("Label", text: $customLabel)
                    Picker("Frequency", selection: $customFrequency) {
                        ForEach(AlertFrequency.allCases, id: \.self) { f in
                            Text(f.label).tag(f)
                        }
                    }
                }
                .navigationTitle("Custom alert")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showAddCustom = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let rule = AlertRule(
                                daysRemainingThreshold: customDays,
                                label: customLabel,
                                detail: "Custom threshold",
                                frequency: customFrequency,
                                isEnabled: true,
                                isCustom: true
                            )
                            rule.tracker = tracker
                            tracker.alertRules.append(rule)
                            try? modelContext.save()
                            reschedule()
                            showAddCustom = false
                        }
                    }
                }
            }
        }
        .onChange(of: tracker.alertRules.map(\.isEnabled)) { _, _ in reschedule() }
    }

    private func alertRow(_ rule: AlertRule) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.label)
                    .font(.subheadline.weight(.semibold))
                Text(rule.detail)
                    .font(.caption)
                    .foregroundStyle(StaydayoTheme.inkMuted)
                Picker("Frequency", selection: Binding(
                    get: { rule.frequency },
                    set: { rule.frequency = $0; try? modelContext.save(); reschedule() }
                )) {
                    ForEach(AlertFrequency.allCases, id: \.self) { f in
                        Text(f.label).tag(f)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .font(.caption2)
            }
            Spacer()
            Toggle("", isOn: Bindable(rule).isEnabled)
                .labelsHidden()
                .tint(StaydayoTheme.gold)
                .onChange(of: rule.isEnabled) { _, _ in
                    try? modelContext.save()
                    reschedule()
                }
        }
        .padding(16)
        .staydayoGlassCard()
    }

    private var notificationPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notification preview")
                .font(.caption.weight(.semibold))
                .foregroundStyle(StaydayoTheme.inkMuted)
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.fill")
                    .foregroundStyle(StaydayoTheme.gold)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Staydayo")
                        .font(.caption.weight(.bold))
                    Text(
                        "\(max(stats.daysLeft, 14)) days left on \(tracker.title). You have used \(stats.usedDays) of \(stats.maxDays) days."
                    )
                    .font(.caption)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func reschedule() {
        Task {
            await NotificationScheduler.rescheduleAll(trackers: [tracker], entries: dayEntries)
        }
    }
}
