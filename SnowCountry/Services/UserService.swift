import FirebaseFirestore

struct UserService {
    // These could probably go into some sort of utility file
    static func fetchUser(withUID uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    static func createUser(withUID uid: String, username: String, email: String) async throws {
        let user = User(id: uid, username: username, email: email)
        try Firestore.firestore().collection("users").document(uid).setData(from: user)
    }
    
    // Function to fetch all users from the database
    static func fetchAllUsers() async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: User.self) })
    }
}
