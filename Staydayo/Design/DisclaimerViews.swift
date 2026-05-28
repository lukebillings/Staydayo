import SwiftUI

enum StaydayoCopy {
    static let disclaimer =
        "Staydayo does not provide tax, legal, or financial advice. Day counts are estimates based on your entries—confirm rules with a qualified adviser."

    static let disclaimerShort = "Not tax, legal, or financial advice."

    static let dayCountingSummary =
        """
        Each calendar day you mark as present in a country counts as one full day for that country (midnight to midnight in your device’s time zone).

        If you are in two countries on the same day, both countries receive one day for that date.

        Trackers sum days only for the countries linked to that tracker. Schengen uses a simplified rolling count (days in the last 180 days)—always verify official rules.
        """
}

struct DisclaimerBanner: View {
    var compact: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(compact ? .caption : .subheadline)
                .foregroundStyle(StaydayoTheme.goldDark)
            Text(compact ? StaydayoCopy.disclaimerShort : StaydayoCopy.disclaimer)
                .font(compact ? .caption2 : .caption)
                .foregroundStyle(StaydayoTheme.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(compact ? 10 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StaydayoTheme.coralLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct DisclaimerFooter: View {
    var body: some View {
        Text(StaydayoCopy.disclaimerShort)
            .font(.caption2)
            .foregroundStyle(StaydayoTheme.inkMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}
