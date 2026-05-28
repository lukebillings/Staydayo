import SwiftUI

struct PaywallView: View {
    @Bindable var viewModel: PaywallViewModel
    var onUnlocked: () -> Void = {}

    var body: some View {
        ZStack {
            StaydayoTheme.paywallGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    hero
                    benefitsSection
                    planCard
                    ctaSection
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .alert("Something went wrong", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(StaydayoTheme.coral.opacity(0.18))
                    .frame(width: 88, height: 88)
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(StaydayoTheme.coralDark)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 28)

            Text(viewModel.headline)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(StaydayoTheme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.subheadline)
                .font(.subheadline)
                .foregroundStyle(StaydayoTheme.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(StaydayoTheme.coral)
                Text(viewModel.socialProof)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(StaydayoTheme.inkMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(StaydayoTheme.coralLight.opacity(0.7))
            .clipShape(Capsule())
        }
        .padding(.bottom, 28)
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(spacing: 14) {
            ForEach(Array(viewModel.benefits.enumerated()), id: \.offset) { _, benefit in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: benefit.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(StaydayoTheme.ctaGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(benefit.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(StaydayoTheme.ink)
                        Text(benefit.detail)
                            .font(.caption)
                            .foregroundStyle(StaydayoTheme.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(20)
        .background(.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(StaydayoTheme.coral.opacity(0.15), lineWidth: 1)
        )
        .padding(.bottom, 24)
    }

    // MARK: - Plan

    private var planCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("MOST POPULAR")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(StaydayoTheme.success)
                    .clipShape(Capsule())
                Spacer()
            }
            .padding(.bottom, 12)

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.planTitle)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(StaydayoTheme.ink)
                    Text(viewModel.planSubtitle)
                        .font(.caption)
                        .foregroundStyle(StaydayoTheme.inkMuted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.yearlyPrice)
                        .font(.title.weight(.bold))
                        .foregroundStyle(StaydayoTheme.coralDark)
                    Text("\(viewModel.yearlyPricePerMonth)/mo")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(StaydayoTheme.inkMuted)
                }
            }

            Divider()
                .padding(.vertical, 14)

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(StaydayoTheme.success)
                Text("Save vs paying monthly — one simple yearly price")
                    .font(.caption)
                    .foregroundStyle(StaydayoTheme.inkMuted)
                Spacer(minLength: 0)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
                .shadow(color: StaydayoTheme.coral.opacity(0.22), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(StaydayoTheme.coral, lineWidth: 2)
        )
        .padding(.bottom, 20)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 14) {
            Button {
                viewModel.purchase()
            } label: {
                Group {
                    if viewModel.isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Unlock yearly access — \(viewModel.yearlyPrice)")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(StaydayoTheme.ctaGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: StaydayoTheme.coralDark.opacity(0.35), radius: 12, y: 6)
            .disabled(viewModel.isPurchasing)
            .onChange(of: viewModel.isPurchasing) { _, purchasing in
                if !purchasing, PaywallViewModel.hasActiveSubscription {
                    onUnlocked()
                }
            }

            Text(viewModel.guarantee)
                .font(.caption2)
                .foregroundStyle(StaydayoTheme.inkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 12) {
            Button("Restore purchases") {
                viewModel.restorePurchases()
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(StaydayoTheme.coralDark)

            HStack(spacing: 16) {
                Link("Terms", destination: URL(string: "https://staydayo.com/terms")!)
                Text("·")
                Link("Privacy", destination: URL(string: "https://staydayo.com/privacy")!)
            }
            .font(.caption2)
            .foregroundStyle(StaydayoTheme.inkMuted)
        }
    }
}

#Preview {
    PaywallView(viewModel: PaywallViewModel())
}
