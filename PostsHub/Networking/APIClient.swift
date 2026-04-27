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
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try decoder.decode(UsersResponse.self, from: data).users
    }

    func searchPosts(query: String) async throws -> [Post] {
        var components = URLComponents(url: baseURL.appendingPathComponent("posts/search"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try decoder.decode(PostsResponse.self, from: data).posts
    }
}
