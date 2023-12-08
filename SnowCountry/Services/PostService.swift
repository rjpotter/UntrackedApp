import Foundation
import FirebaseFirestore

struct PostService {
    static func fetchAllPosts() async throws -> [Post] {
        let snapshot = try await Firestore.firestore().collection("posts").getDocuments()
        var posts = try snapshot.documents.compactMap({ document in
            let post = try document.data(as: Post.self)
            return post
        })
        
        for i in 0 ..< posts.count {
            let post = posts[i]
            let ownerUID = post.ownerUID
            let postUser = try await UserService.fetchUser(withUID: ownerUID)
            posts[i].user = postUser
        }
        
        return posts
    }
    
    static func fetchUserPosts(uid: String) async throws -> [Post] {
        let snapshot = try await Firestore.firestore().collection("posts").whereField("ownerUID", isEqualTo: uid).getDocuments()
        return try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
    }
    
    static func fetchPost(uid: String) async throws -> Post {
        let snapshot = try await Firestore.firestore().collection("posts").document(uid).getDocument()
        return try snapshot.data(as: Post.self)
    }
    
    static func addLike(toPost: String) async throws {
        var data = [String: Any]()
        let post = try await fetchPost(uid: toPost)
        
        data["likes"] = post.likes + 1
        try await Firestore.firestore().collection("posts").document(toPost).updateData(data)
    }
    
    static func removeLike(toPost: String) async throws {
        var data = [String: Any]()
        let post = try await fetchPost(uid: toPost)
        
        data["likes"] = post.likes - 1
        try await Firestore.firestore().collection("posts").document(toPost).updateData(data)
    }
}
