import SwiftUI

struct RootView: View {
    @State private var paywallViewModel = PaywallViewModel()
    @State private var homeViewModel = HomeViewModel()
    @State private var isUnlocked = PaywallViewModel.hasActiveSubscription

    var body: some View {
        Group {
            if isUnlocked {
                HomeView(viewModel: homeViewModel)
            } else {
                PaywallView(viewModel: paywallViewModel) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isUnlocked = true
                    }
                }
            }
        }
        .tint(StaydayoTheme.coral)
    }
}

#Preview("Paywall gate") {
    RootView()
}
