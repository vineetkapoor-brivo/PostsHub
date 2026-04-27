import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let phone: String
    let image: String
    let address: Address

    var name: String { "\(firstName) \(lastName)" }
}

struct Address: Codable, Equatable, Hashable {
    let address: String
    let city: String
    let state: String
    let postalCode: String
    let coordinates: Coordinates
}

struct Coordinates: Codable, Equatable, Hashable {
    let lat: String
    let lng: String
}
