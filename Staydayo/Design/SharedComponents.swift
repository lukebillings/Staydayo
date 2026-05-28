import SwiftUI

struct StaydayoHeader: View {
    let title: String
    var showLogo: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            if showLogo {
                ZStack {
                    Circle()
                        .fill(StaydayoTheme.gold.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "bird.fill")
                        .foregroundStyle(StaydayoTheme.goldDark)
                }
            }
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(StaydayoTheme.ink)
            Spacer()
        }
    }
}

struct TrackerProgressCard: View {
    let tracker: Tracker
    let stats: TrackerStats
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(flagLine)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tracker.title)
                            .font(.headline)
                            .foregroundStyle(StaydayoTheme.ink)
                        Text(stats.periodDescription)
                            .font(.caption)
                            .foregroundStyle(StaydayoTheme.inkMuted)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(stats.daysLeft)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(StaydayoTheme.goldDark)
                        Text("days left")
                            .font(.caption2)
                            .foregroundStyle(StaydayoTheme.inkMuted)
                    }
                }

                HStack {
                    Text("\(stats.usedDays) / \(stats.maxDays) used")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(StaydayoTheme.inkMuted)
                    Spacer()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(StaydayoTheme.navy.opacity(0.12))
                        Capsule()
                            .fill(StaydayoTheme.progressGold)
                            .frame(width: max(4, geo.size.width * stats.progress))
                    }
                }
                .frame(height: 8)
            }
            .padding(18)
            .staydayoGlassCard()
        }
        .buttonStyle(.plain)
    }

    private var flagLine: String {
        tracker.countryCodes.prefix(3).map { CountryCatalog.flag(for: $0) }.joined()
    }
}

struct CountryPickerRow: View {
    @Binding var selectedCode: String

    var body: some View {
        Picker("Country", selection: $selectedCode) {
            ForEach(CountryCatalog.popular, id: \.code) { country in
                Text("\(country.flag) \(country.name)").tag(country.code)
            }
        }
        .pickerStyle(.menu)
    }
}
