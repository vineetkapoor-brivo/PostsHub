import Foundation
import Combine

final class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var users: [User] = []
    @Published var favoriteIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var refreshTimer: Timer?
    private var searchTask: Task<Void, Never>?

    init() {
        startAutoRefresh()
    }

    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task { await self.refresh() }
        }
    }

    func refresh() async {
        Log.store.event("refresh start")
        self.isLoading = true
        do {
            let fetched = try await APIClient.shared.fetchPosts()
            self.posts = fetched
            self.isLoading = false
            Log.store.event("refresh ok: posts=\(fetched.count)")
        } catch {
            self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
            self.isLoading = false
            Log.store.event("refresh failed: \(error.localizedDescription)")
        }
    }

    func loadUsers() async {
        Log.store.event("loadUsers start")
        do {
            let fetched = try await APIClient.shared.fetchUsers()
            self.users = fetched
            Log.store.event("loadUsers ok: users=\(fetched.count)")
        } catch {
            self.errorMessage = "Failed to load users: \(error.localizedDescription)"
            Log.store.event("loadUsers failed: \(error.localizedDescription)")
        }
    }

    func searchInline(query: String) {
        Log.store.event("searchInline q='\(query)'")
        searchTask?.cancel()
        guard !query.isEmpty else {
            Log.store.event("searchInline empty -> refresh")
            Task { await refresh() }
            return
        }
        searchTask = Task {
            let results = (try? await APIClient.shared.searchPosts(query: query)) ?? []
            let processed = results.sorted { $0.id < $1.id }
            Log.store.event("searchInline assign q='\(query)' results=\(processed.count)")
            self.posts = processed
        }
    }

    func toggleFavorite(_ postId: Int) {
        if favoriteIds.contains(postId) {
            favoriteIds.remove(postId)
        } else {
            favoriteIds.insert(postId)
        }
        Log.store.event("toggleFavorite id=\(postId) nowFav=\(favoriteIds.contains(postId)) total=\(favoriteIds.count)")
    }

    func updatePost(_ post: Post) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else {
            Log.store.event("updatePost id=\(post.id) NOT FOUND in posts (count=\(posts.count))")
            return
        }
        posts[idx] = post
        Log.store.event("updatePost id=\(post.id) idx=\(idx) titleLen=\(post.title.count) bodyLen=\(post.body.count)")
    }

    func diagnosticsDump() {
        Log.store.event("── DIAGNOSTICS ──")
        Log.store.event("posts.count=\(posts.count) users.count=\(users.count) favoriteIds=\(Array(favoriteIds).sorted()) isLoading=\(isLoading) error='\(errorMessage ?? "nil")'")
    }
}
