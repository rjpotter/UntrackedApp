import Foundation

struct User: Identifiable, Codable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
    // Runs, posts
}
