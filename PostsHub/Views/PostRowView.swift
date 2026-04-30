import SwiftUI

struct PostRowView: View {
    let post: Post
    @EnvironmentObject var store: PostStore
    @State private var isFavorite: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                Text(post.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                isFavorite.toggle()
                Log.row.event("heart tap id=\(post.id) localFav=\(isFavorite) storeFav=\(store.favoriteIds.contains(post.id))")
                if isFavorite {
                    store.favoriteIds.insert(post.id)
                } else {
                    store.favoriteIds.remove(post.id)
                }
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .red : .gray)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .onAppear {
            Log.row.event("onAppear id=\(post.id) localFav=\(isFavorite) storeFav=\(store.favoriteIds.contains(post.id))")
        }
        .onDisappear {
            Log.row.event("onDisappear id=\(post.id) localFav=\(isFavorite) storeFav=\(store.favoriteIds.contains(post.id))")
        }
    }
}
