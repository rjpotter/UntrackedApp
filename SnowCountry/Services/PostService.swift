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
        let snapshot = try await Firestore.firestore().collection("Posts").whereField("ownerUID", isEqualTo: uid).getDocuments()
        return try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
    }
}
