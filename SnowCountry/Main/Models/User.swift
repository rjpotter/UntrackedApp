import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var bannerImageURL: String?
    var friends: [String]?
    var pendingFriends: [String]?
    var friendInvites: [String]?
    var likedPosts: [String]?

    init(id: String = UUID().uuidString, username: String, email: String, profileImageURL: String? = nil, bannerImageURL: String? = nil, friends: [String]? = nil, pendingFriends: [String]? = nil, friendInvites: [String]? = nil, likedPosts: [String]? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImageURL = profileImageURL
        self.bannerImageURL = bannerImageURL
        self.friends = friends
        self.pendingFriends = pendingFriends
        self.friendInvites = friendInvites
        self.likedPosts = likedPosts
    }

    // Custom decoding to handle missing fields gracefully
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? "Unknown"
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? "Unknown"
        self.profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        self.bannerImageURL = try container.decodeIfPresent(String.self, forKey: .bannerImageURL)
        self.friends = try container.decodeIfPresent([String].self, forKey: .friends)
        self.pendingFriends = try container.decodeIfPresent([String].self, forKey: .pendingFriends)
        self.friendInvites = try container.decodeIfPresent([String].self, forKey: .friendInvites)
        self.likedPosts = try container.decodeIfPresent([String].self, forKey: .likedPosts)
    }
}

