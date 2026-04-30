import Foundation

actor APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://dummyjson.com")!
    private let decoder = JSONDecoder()

    private init() {}

    private struct PostsResponse: Decodable {
        let posts: [Post]
    }

    private struct UsersResponse: Decodable {
        let users: [User]
    }

    func fetchPosts() async throws -> [Post] {
        var components = URLComponents(url: baseURL.appendingPathComponent("posts"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "limit", value: "100")]
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try decoder.decode(PostsResponse.self, from: data).posts
    }

    func fetchUsers() async throws -> [User] {
        var components = URLComponents(url: baseURL.appendingPathComponent("users"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "limit", value: "100")]
        let url = components.url!
        Log.api.event("GET \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(from: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        Log.api.event("← users status=\(status) bytes=\(data.count)")
        do {
            let users = try decoder.decode(UsersResponse.self, from: data).users
            Log.api.event("decoded users count=\(users.count)")
            return users
        } catch {
            Log.dumpDecodingError(error, data: data, logger: Log.api)
            throw error
        }
    }

    func searchPosts(query: String) async throws -> [Post] {
        var components = URLComponents(url: baseURL.appendingPathComponent("posts/search"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        let url = components.url!
        Log.api.event("GET \(url.absoluteString) (q='\(query)')")
        let (data, response) = try await URLSession.shared.data(from: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        Log.api.event("← search status=\(status) bytes=\(data.count)")
        do {
            let posts = try decoder.decode(PostsResponse.self, from: data).posts
            Log.api.event("decoded search posts count=\(posts.count) for q='\(query)'")
            return posts
        } catch {
            Log.dumpDecodingError(error, data: data, logger: Log.api)
            throw error
        }
    }
}
