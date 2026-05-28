import Foundation
import Observation

@Observable
final class PaywallViewModel {
    let yearlyPrice = "£99.99"
    let yearlyPricePerMonth = "£8.33"
    let planTitle = "Yearly"
    let planSubtitle = "Full access · billed once per year"

    var isPurchasing = false
    var showError = false
    var errorMessage = ""

    let headline = "Never lose track of your stay days again"
    let subheadline = "Stay compliant, plan smarter, and travel with confidence."

    let benefits: [(icon: String, title: String, detail: String)] = [
        ("calendar.badge.clock", "Stay-day tracking", "Automatic counts for visa and tax residency limits."),
        ("bell.badge.fill", "Smart alerts", "Warnings before you hit thresholds."),
        ("map.fill", "Trip planning", "Multi-country timelines in one place."),
        ("lock.shield.fill", "Private & secure", "Your travel data stays on your device."),
    ]

    let socialProof = "Trusted by travelers in 40+ countries"
    let guarantee = "Cancel anytime in Settings · no hidden fees"

    func purchase() {
        guard !isPurchasing else { return }
        isPurchasing = true

        // TODO: Wire StoreKit 2 product purchase for yearly subscription.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.isPurchasing = false
            self?.completePurchase()
        }
    }

    func restorePurchases() {
        // TODO: Wire StoreKit 2 `Transaction.currentEntitlements`.
    }

    /// Called after a successful purchase — replace with StoreKit callback.
    func completePurchase() {
        UserDefaults.standard.set(true, forKey: Self.subscriptionKey)
    }

    static let subscriptionKey = "staydayo.hasActiveSubscription"

    static var hasActiveSubscription: Bool {
        UserDefaults.standard.bool(forKey: subscriptionKey)
    }
}
