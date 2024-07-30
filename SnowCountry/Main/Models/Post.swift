import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable, Hashable {
    var id: String
    var ownerUID: String
    var caption: String
    var likedBy: [String]? // Array of user IDs
    var likes: Int
    var imageURL: String?
    var imageURLs: [String]?
    var stokeLevel: Int?
    var taggedUsers: [User]?
    var timestamp: Timestamp
    var user: User?

    // Initializer including all properties
    init(id: String = UUID().uuidString,
         ownerUID: String,
         caption: String,
         likedBy: [String]? = nil,
         likes: Int = 0,
         imageURL: String? = nil,
         imageURLs: [String]? = nil,
         stokeLevel: Int? = nil,
         taggedUsers: [User]? = nil,
         timestamp: Timestamp = Timestamp(),
         user: User? = nil) {
        self.id = id
        self.ownerUID = ownerUID
        self.caption = caption
        self.likedBy = likedBy
        self.likes = likes
        self.imageURL = imageURL
        self.imageURLs = imageURLs
        self.stokeLevel = stokeLevel
        self.taggedUsers = taggedUsers
        self.timestamp = timestamp
        self.user = user
    }
}

func parsePostData(from document: DocumentSnapshot) -> Post? {
    guard let data = document.data() else { return nil }
    
    let id = data["id"] as? String ?? ""
    let ownerUID = data["ownerUID"] as? String ?? ""
    let caption = data["caption"] as? String ?? ""
    let likedBy = data["likedBy"] as? [String] ?? []
    let likes = data["likes"] as? Int ?? 0
    let imageURLs = data["imageURLs"] as? [String]
    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
    let stokeLevel = data["stokeLevel"] as? Int
    
    // Directly decode taggedUsers as [User] if the Firestore data is already in the correct format
    let taggedUsersData = data["taggedUsers"] as? [[String: Any]] ?? []
    let taggedUsers: [User] = taggedUsersData.compactMap { userData in
        guard let email = userData["email"] as? String,
              let id = userData["id"] as? String,
              let username = userData["username"] as? String,
              let profileImageURL = userData["profileImageURL"] as? String else { return nil }
        return User(id: id, username: username, email: email, profileImageURL: profileImageURL)
    }
    
    return Post(id: id,
                ownerUID: ownerUID,
                caption: caption,
                likedBy: likedBy,
                likes: likes,
                imageURL: nil, // Set this to nil if not used
                imageURLs: imageURLs,
                stokeLevel: stokeLevel,
                taggedUsers: taggedUsers,
                timestamp: timestamp)
}

