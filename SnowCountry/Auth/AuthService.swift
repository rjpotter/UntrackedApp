import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class AuthService {
    // Var to store the user session
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    static let shared = AuthService()
    
    init() {
        Task { try await loadUserData() }
    }

    @MainActor
    func login(withEmail email: String, _ password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await loadUserData()
        } catch {
            print("Failed to login user with error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createUser(_ username: String, _ email: String, _ password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            await uploadUserData(uid: result.user.uid, username: username, email: email)
        } catch {
            print("Failed to add user with error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        guard let currentUID = userSession?.uid else { return }
        let snapshot = try await Firestore.firestore().collection("users").document(currentUID).getDocument()
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
    }
    
    func uploadUserData(uid: String, username: String, email: String) async {
        let user = User(id: uid, username: username, email: email)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        self.currentUser = user
        try? await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
    }
}
