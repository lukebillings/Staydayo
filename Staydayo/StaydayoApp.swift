import SwiftUI

@main
struct StaydayoApp: App {
    @State private var homeViewModel = HomeViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: homeViewModel)
        }
    }
}
