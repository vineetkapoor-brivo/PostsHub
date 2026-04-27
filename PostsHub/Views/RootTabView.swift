import SwiftUI

struct RootTabView: View {
    @StateObject private var store = PostStore()

    var body: some View {
        TabView {
            PostListView()
                .tabItem { Label("Posts", systemImage: "list.bullet") }
            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "heart.fill") }
        }
        .environmentObject(store)
    }
}
