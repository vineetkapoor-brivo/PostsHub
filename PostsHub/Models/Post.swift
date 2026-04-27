import Foundation

struct Post: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let userId: Int
    var title: String
    var body: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case body
    }
}
