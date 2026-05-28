import SwiftData
import SwiftUI

@main
struct StaydayoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(StaydayoModelContainer.shared)
    }
}
