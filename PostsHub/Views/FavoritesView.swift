import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var store: PostStore

    var favorites: [Post] {
        store.posts.filter { store.favoriteIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No favorites yet")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(favorites) { post in
                            NavigationLink(value: post) {
                                PostRowView(post: post)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
            }
            .onAppear {
                Log.favorites.event("onAppear count=\(favorites.count) ids=\(Array(store.favoriteIds).sorted()) postsLoaded=\(store.posts.count)")
            }
        }
    }
}
