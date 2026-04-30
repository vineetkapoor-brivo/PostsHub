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
                        Log.list.event("onDelete indexSet=\(Array(indexSet)) filtered=\(filteredPosts.count) store=\(store.posts.count) selectedUserId=\(selectedUserId.map(String.init) ?? "nil")")
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
                Log.list.event("query changed -> '\(newValue)'")
                store.searchInline(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                            store.diagnosticsDump()
                        }
                    )
                }
            }
            .sheet(isPresented: $showingFilter) {
                UserFilterSheet(selectedUserId: $selectedUserId)
            }
            .refreshable {
                Log.list.event("pull-to-refresh")
                await store.refresh()
            }
            .task {
                Log.list.event(".task fired (storePosts=\(store.posts.count) storeUsers=\(store.users.count))")
                await store.refresh()
                await store.loadUsers()
            }
            .onAppear {
                Log.list.event("onAppear filtered=\(filteredPosts.count) store=\(store.posts.count) selectedUserId=\(selectedUserId.map(String.init) ?? "nil")")
            }
            .alert("Error", isPresented: .constant(store.errorMessage != nil)) {
                Button("OK") { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
}
