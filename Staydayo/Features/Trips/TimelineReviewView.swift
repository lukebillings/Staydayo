import SwiftData
import SwiftUI

struct TimelineReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TripSegment.startDay, order: .reverse) private var trips: [TripSegment]
    @Query(sort: \DayEntry.dayStart, order: .reverse) private var dayEntries: [DayEntry]

    @State private var showAddTrip = false
    @State private var editingTrip: TripSegment?

    private var unconfirmed: [TripSegment] { trips.filter { !$0.isConfirmed } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DisclaimerBanner(compact: true)

                    correctionCard(
                        title: "Unconfirmed stays",
                        subtitle: "Confirm or edit trips you've logged",
                        items: unconfirmed.map { "\(CountryCatalog.flag(for: $0.countryCode)) \(CountryCatalog.name(for: $0.countryCode)) · \(dayCount($0)) days" }
                    )

                    correctionCard(
                        title: "Missing days",
                        subtitle: "Gaps between recorded stays (review manually)",
                        items: missingDayHints()
                    )

                    correctionCard(
                        title: "All trips",
                        subtitle: "Edit past trips",
                        items: trips.map { tripLine($0) }
                    )

                    HStack(spacing: 12) {
                        Button("Confirm all") { confirmAll() }
                            .buttonStyle(StaydayoPrimaryButtonStyle())
                        StaydayoGlassButton("Add past trip", systemImage: "plus") {
                            showAddTrip = true
                        }
                    }

                    DisclaimerFooter()
                }
                .padding(20)
            }
            .staydayoScreenBackground()
            .navigationTitle("Timeline review")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddTrip = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddTrip) {
                AddTripSheet()
            }
            .sheet(item: $editingTrip) { trip in
                EditTripSheet(trip: trip)
            }
        }
    }

    private func correctionCard(title: String, subtitle: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(StaydayoTheme.inkMuted)
            if items.isEmpty {
                Text("Nothing here — you're up to date.")
                    .font(.subheadline)
                    .foregroundStyle(StaydayoTheme.inkMuted)
            } else {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    Divider()
                }
            }
        }
        .padding(18)
        .staydayoGlassCard()
    }

    private func dayCount(_ trip: TripSegment) -> Int {
        DayCountingService.daysBetween(start: trip.startDay, end: trip.endDay).count
    }

    private func tripLine(_ trip: TripSegment) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateStyle = .medium
        let status = trip.isConfirmed ? "Confirmed" : "Unconfirmed"
        return "\(CountryCatalog.flag(for: trip.countryCode)) \(f.string(from: trip.startDay)) – \(f.string(from: trip.endDay)) · \(status)"
    }

    private func missingDayHints() -> [String] {
        guard dayEntries.count >= 2 else { return [] }
        let sorted = dayEntries.sorted { $0.dayStart < $1.dayStart }
        var hints: [String] = []
        let calendar = Calendar.current
        for i in 1..<sorted.count {
            let prev = sorted[i - 1].dayStart
            let next = sorted[i].dayStart
            if let gap = calendar.dateComponents([.day], from: prev, to: next).day, gap > 1 {
                hints.append("Gap of \(gap - 1) day(s) before \(next.formatted(date: .abbreviated, time: .omitted))")
            }
        }
        return Array(hints.prefix(5))
    }

    private func confirmAll() {
        Task { @MainActor in
            for trip in unconfirmed {
                try? PresenceService.confirmTrip(trip, context: modelContext)
            }
        }
    }
}

struct AddTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var countryCode = "ES"
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var endDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                CountryPickerRow(selectedCode: $countryCode)
                DatePicker("From", selection: $startDate, displayedComponents: .date)
                DatePicker("To", selection: $endDate, displayedComponents: .date)
                DisclaimerBanner(compact: true)
            }
            .navigationTitle("Add past trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trip = TripSegment(
                            countryCode: countryCode,
                            startDay: startDate,
                            endDay: endDate,
                            isConfirmed: false
                        )
                        modelContext.insert(trip)
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: TripSegment

    var body: some View {
        NavigationStack {
            Form {
                CountryPickerRow(selectedCode: $trip.countryCode)
                DatePicker("From", selection: $trip.startDay, displayedComponents: .date)
                DatePicker("To", selection: $trip.endDay, displayedComponents: .date)
                Toggle("Confirmed", isOn: $trip.isConfirmed)
                Button("Confirm & apply days") {
                    try? PresenceService.confirmTrip(trip, context: modelContext)
                    dismiss()
                }
                Button("Delete trip", role: .destructive) {
                    modelContext.delete(trip)
                    try? modelContext.save()
                    dismiss()
                }
            }
            .navigationTitle("Edit trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
