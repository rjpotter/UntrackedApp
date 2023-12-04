import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var bannerImageURL: String?
    var friends: [String]? // Friends referenced by their uid
}
