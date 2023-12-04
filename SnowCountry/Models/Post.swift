import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let ownerUID: String
    let caption: String
    var likes: Int // Snowflakes or something?
    var imageURL: String?
    var runURL: String?
    let timestamp: Timestamp
    var user: User?
}
