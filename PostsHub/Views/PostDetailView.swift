import SwiftUI

struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var store: PostStore
    @State private var draft: Post
    @State private var avatarURL: URL
    @State private var showSavedToast: Bool = false

    init(post: Post) {
        self.post = post
        self._draft = State(initialValue: post)
        let raw = "https://avatars.example.com/user \(post.userId).png"
        self._avatarURL = State(initialValue: URL(string: raw, encodingInvalidCharacters: false)!)
    }

    var body: some View {
        Form {
            Section("Author") {
                HStack(spacing: 12) {
                    AsyncImage(url: avatarURL) { image in
                        image.resizable().clipShape(Circle())
                    } placeholder: {
                        Circle().fill(.gray.opacity(0.3))
                    }
                    .frame(width: 48, height: 48)

                    if let user = store.users.first(where: { $0.id == post.userId }) {
                        VStack(alignment: .leading) {
                            Text(user.name).font(.headline)
                            Text("@\(user.username)").font(.caption).foregroundStyle(.secondary)
                        }
                    } else {
                        Text("User #\(post.userId)")
                    }
                }
            }

            Section("Title") {
                TextField("Title", text: $draft.title, axis: .vertical)
            }

            Section("Body") {
                TextEditor(text: $draft.body)
                    .frame(minHeight: 160)
            }

            Section {
                Button {
                    if store.favoriteIds.contains(post.id) {
                        store.favoriteIds.remove(post.id)
                    } else {
                        store.favoriteIds.insert(post.id)
                    }
                } label: {
                    Label(
                        store.favoriteIds.contains(post.id) ? "Remove from Favorites" : "Add to Favorites",
                        systemImage: store.favoriteIds.contains(post.id) ? "heart.fill" : "heart"
                    )
                }

                Button("Save Changes") {
                    showSavedToast = true
                }
                .disabled(draft == post)
            }
        }
        .navigationTitle("Post #\(post.id)")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .top) {
            if showSavedToast {
                Text("Saved")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        showSavedToast = false
                    }
            }
        }
    }
}
