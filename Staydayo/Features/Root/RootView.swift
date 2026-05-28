import SwiftUI

struct RootView: View {
    @State private var paywallViewModel = PaywallViewModel()
    @State private var isUnlocked = PaywallViewModel.hasActiveSubscription
    @AppStorage("staydayo.hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    @State private var showDisclaimerSheet = false

    var body: some View {
        Group {
            if isUnlocked {
                MainTabView()
                    .onAppear {
                        StaydayoBootstrap.seedIfNeeded(container: StaydayoModelContainer.shared)
                        if !hasAcceptedDisclaimer {
                            showDisclaimerSheet = true
                        }
                    }
                    .sheet(isPresented: $showDisclaimerSheet) {
                        DisclaimerOnboardingSheet(hasAccepted: $hasAcceptedDisclaimer)
                    }
            } else {
                PaywallView(viewModel: paywallViewModel) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isUnlocked = true
                    }
                }
            }
        }
        .tint(StaydayoTheme.gold)
        .preferredColorScheme(.light)
    }
}

struct DisclaimerOnboardingSheet: View {
    @Binding var hasAccepted: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Important")
                        .font(.title.weight(.bold))
                    DisclaimerBanner()
                    Text(StaydayoCopy.dayCountingSummary)
                        .font(.body)
                        .foregroundStyle(StaydayoTheme.inkMuted)
                    Button("I understand — continue") {
                        hasAccepted = true
                        dismiss()
                    }
                    .buttonStyle(StaydayoPrimaryButtonStyle())
                }
                .padding(24)
            }
            .staydayoScreenBackground()
            .interactiveDismissDisabled()
        }
    }
}

#Preview("Paywall gate") {
    RootView()
}
