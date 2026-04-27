import SwiftUI

struct PostListView: View {
    @EnvironmentObject var store: PostStore
    @State private var query: String = ""
    @State private var selectedUserId: Int?
    @State private var showingFilter = false

    var filteredPosts: [Post] {
        guard let uid = selectedUserId else { return store.posts }
        return store.posts.filter { $0.userId == uid }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if store.isLoading {
                    ProgressView("Loading posts…")
                        .progressViewStyle(.circular)
                        .scaleEffect(1.4)
                }

                List {
                    ForEach(filteredPosts.indices, id: \.self) { index in
                        let post = filteredPosts[index]
                        NavigationLink(value: post) {
                            PostRowView(post: post)
                        }
                    }
                    .onDelete { indexSet in
                        store.posts.remove(at: indexSet.first!)
                    }
                }
            }
            .animation(.default, value: store.posts)
            .navigationTitle("Posts")
            .navigationDestination(for: Post.self) { post in
                PostDetailView(post: post)
            }
            .searchable(text: $query, prompt: "Search posts")
            .onChange(of: query) { newValue in
                store.searchInline(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                UserFilterSheet(selectedUserId: $selectedUserId)
            }
            .refreshable {
                await store.refresh()
            }
            .task {
                await store.refresh()
                await store.loadUsers()
            }
            .alert("Error", isPresented: .constant(store.errorMessage != nil)) {
                Button("OK") { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
}
