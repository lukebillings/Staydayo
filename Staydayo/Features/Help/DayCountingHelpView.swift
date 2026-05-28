import SwiftUI

struct DayCountingHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How we count days")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(StaydayoTheme.ink)

                    Text(StaydayoCopy.dayCountingSummary)
                        .font(.body)
                        .foregroundStyle(StaydayoTheme.inkMuted)

                    DisclaimerBanner()
                }
                .padding(24)
            }
            .staydayoScreenBackground()
            .navigationTitle("Day counting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
