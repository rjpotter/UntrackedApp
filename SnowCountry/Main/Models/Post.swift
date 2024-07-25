import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable, Hashable {
    var id: String
    var ownerUID: String
    var caption: String
    var likes: Int
    var imageURL: String?
    var imageURLs: [String]?
    var timestamp: Timestamp
    var user: User?

    // Initializer with default values for some properties
    init(id: String = UUID().uuidString,
         ownerUID: String,
         caption: String,
         likes: Int = 0,
         imageURLs: [String]? = nil,
         runURL: String? = nil,
         timestamp: Timestamp = Timestamp(),
         user: User? = nil) {
        self.id = id
        self.ownerUID = ownerUID
        self.caption = caption
        self.likes = likes
        self.imageURLs = imageURLs
        self.timestamp = timestamp
        self.user = user
    }
}
