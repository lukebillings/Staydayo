import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                viewModel.title,
                systemImage: "globe.europe.africa.fill",
                description: Text("Home screen placeholder")
            )
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
