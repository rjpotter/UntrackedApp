import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let ownerUID: String
    let caption: String
    var likes: Int
    var imageURL: String?
    var imageURLs: [String]? // This should be an array to support multiple images
    var runURL: String?
    let timestamp: Timestamp
    var user: User?
}

