import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
//    var posts: Array?
//    var friends: Array?
}
