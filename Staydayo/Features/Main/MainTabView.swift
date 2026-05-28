import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case dashboard
    case trips
    case trackers
    case alerts
    case export
    case vault

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .trips: "Trips"
        case .trackers: "Trackers"
        case .alerts: "Alerts"
        case .export: "Export"
        case .vault: "Vault"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "square.grid.2x2.fill"
        case .trips: "calendar"
        case .trackers: "chart.bar.fill"
        case .alerts: "bell.badge.fill"
        case .export: "arrow.up.doc.fill"
        case .vault: "lock.doc.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(MainTab.dashboard.title, systemImage: MainTab.dashboard.systemImage, value: MainTab.dashboard) {
                DashboardView()
            }
            Tab(MainTab.trips.title, systemImage: MainTab.trips.systemImage, value: MainTab.trips) {
                TimelineReviewView()
            }
            Tab(MainTab.trackers.title, systemImage: MainTab.trackers.systemImage, value: MainTab.trackers) {
                TrackersView()
            }
            Tab(MainTab.alerts.title, systemImage: MainTab.alerts.systemImage, value: MainTab.alerts) {
                AlertsHubView()
            }
            Tab(MainTab.export.title, systemImage: MainTab.export.systemImage, value: MainTab.export) {
                ExportView()
            }
            Tab(MainTab.vault.title, systemImage: MainTab.vault.systemImage, value: MainTab.vault) {
                VaultView()
            }
        }
        .tint(StaydayoTheme.gold)
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
