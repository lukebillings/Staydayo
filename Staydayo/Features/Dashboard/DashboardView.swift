import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tracker.createdAt, order: .reverse) private var trackers: [Tracker]
    @Query(sort: \DayEntry.dayStart, order: .reverse) private var dayEntries: [DayEntry]
    @Query private var presences: [ActivePresence]

    @State private var selectedCountry = "ES"
    @State private var showHelp = false
    private var activePresence: ActivePresence? {
        presences.first { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    StaydayoHeader(title: "Staydayo")
                    DisclaimerBanner(compact: true)

                    presenceCard
                    trackersSection
                    DisclaimerFooter()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .staydayoScreenBackground()
            .navigationBarHidden(true)
            .sheet(isPresented: $showHelp) { DayCountingHelpView() }
            .task {
                _ = await NotificationScheduler.requestAuthorization()
                await NotificationScheduler.rescheduleAll(trackers: trackers, entries: dayEntries)
            }
        }
    }

    private var presenceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Where are you now?")
                    .font(.headline)
                Spacer()
                Button {
                    showHelp = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(StaydayoTheme.goldDark)
                }
            }

            CountryPickerRow(selectedCode: $selectedCountry)

            if let active = activePresence {
                HStack {
                    Text("\(CountryCatalog.flag(for: active.countryCode)) In \(CountryCatalog.name(for: active.countryCode))")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("Since \(active.arrivedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(StaydayoTheme.inkMuted)
                }

                Toggle("I've left this country", isOn: Binding(
                    get: { false },
                    set: { if $0 { leaveCountry() } }
                ))
                .tint(StaydayoTheme.gold)
            } else {
                Toggle("I'm in this country now", isOn: Binding(
                    get: { false },
                    set: { if $0 { arriveInCountry() } }
                ))
                .tint(StaydayoTheme.gold)
            }
        }
        .padding(18)
        .staydayoGlassCard()
    }

    private var trackersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your trackers")
                .font(.headline)
                .foregroundStyle(StaydayoTheme.ink)

            if trackers.isEmpty {
                ContentUnavailableView(
                    "No trackers yet",
                    systemImage: "chart.bar",
                    description: Text("Add a tracker to see days remaining.")
                )
                .frame(minHeight: 160)
            } else {
                ForEach(trackers) { tracker in
                    let stats = DayCountingService.stats(for: tracker, entries: dayEntries)
                    NavigationLink {
                        TrackerAlertsView(tracker: tracker)
                    } label: {
                        TrackerProgressCard(tracker: tracker, stats: stats)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func arriveInCountry() {
        Task { @MainActor in
            try? PresenceService.arrive(countryCode: selectedCountry, context: modelContext)
            await NotificationScheduler.rescheduleAll(trackers: trackers, entries: dayEntries)
        }
    }

    private func leaveCountry() {
        Task { @MainActor in
            try? PresenceService.leave(context: modelContext)
            await NotificationScheduler.rescheduleAll(trackers: trackers, entries: dayEntries)
        }
    }
}
