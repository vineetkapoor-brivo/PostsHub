import Foundation
import Combine
@MainActor
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
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { await self?.refresh() }
        }
    }

    func refresh() async {
        self.isLoading = true
        do {
            let fetched = try await APIClient.shared.fetchPosts()
            self.posts = fetched
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func loadUsers() async {
        do {
            let fetched = try await APIClient.shared.fetchUsers()
            self.users = fetched
        } catch {
            self.errorMessage = "Failed to load users: \(error.localizedDescription)"
        }
    }

    func searchInline(query: String) {
        searchTask?.cancel()
        guard !query.isEmpty else {
            Task { await refresh() }
            return
        }
        searchTask = Task {
            let results = (try? await APIClient.shared.searchPosts(query: query)) ?? []
            let processed = results.sorted { $0.id < $1.id }
            self.posts = processed
        }
    }

    func toggleFavorite(_ postId: Int) {
        if favoriteIds.contains(postId) {
            favoriteIds.remove(postId)
        } else {
            favoriteIds.insert(postId)
        }
    }

    func updatePost(_ post: Post) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx] = post
    }
}
