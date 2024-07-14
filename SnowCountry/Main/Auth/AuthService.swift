import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import CryptoKit
import AuthenticationServices

class AuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var signedIn: Bool = false
    
    var currentNonce: String?

    static let shared = AuthService()

    override init() {
        super.init()
        print("AuthService initialized")
        Task {
            do {
                try await loadUserData()
            } catch {
                print("Failed to load user data: \(error.localizedDescription)")
            }
        }
        Auth.auth().addStateDidChangeListener { auth, user in
            self.userSession = user
            self.signedIn = (user != nil)
            if user != nil {
                print("Auth state changed, is signed in")
                Task {
                    do {
                        try await self.loadUserData()
                    } catch {
                        print("Failed to load user data after auth state change: \(error.localizedDescription)")
                    }
                }
            } else {
                self.currentUser = nil
                print("Auth state changed, is signed out")
            }
        }
    }

    @MainActor
    func login(withEmail email: String, _ password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("User logged in with email")
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
            print("User created with email")
            await uploadUserData(uid: result.user.uid, username: username, email: email)
        } catch {
            print("Failed to add user with error: \(error.localizedDescription)")
        }
    }

    @MainActor
    func loadUserData() async throws {
        print("Loading user data...")
        self.userSession = Auth.auth().currentUser
        guard let currentUID = userSession?.uid else {
            print("No current user found")
            return
        }
        print("Fetching user data for UID: \(currentUID)")
        do {
            if let user = try? await UserService.fetchUser(withUID: currentUID) {
                self.currentUser = user
                print("User data loaded: \(self.currentUser?.username ?? "No username")")
            } else {
                // Handle missing user data by creating a default user
                let defaultUsername = "AppleUser" + (currentUID.prefix(5))
                let email = self.userSession?.email ?? "NoEmail"
                print("User data missing, creating default user with username: \(defaultUsername)")
                try await UserService.createUser(withUID: currentUID, username: defaultUsername, email: email)
                self.currentUser = try await UserService.fetchUser(withUID: currentUID)
                print("Default user created and loaded: \(self.currentUser?.username ?? "No username")")
            }
        } catch {
            print("Failed to fetch or create user data: \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.signedIn = false
            print("User signed out")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func uploadUserData(uid: String, username: String, email: String) async {
        let user = User(id: uid, username: username, email: email)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else {
            print("Failed to encode user")
            return
        }
        self.currentUser = user
        do {
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            print("User data uploaded successfully")
        } catch {
            print("Failed to upload user data: \(error.localizedDescription)")
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }

    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error during Apple sign-in: \(error.localizedDescription)")
                    return
                }
                print("Apple sign-in successful!")
                Task {
                    do {
                        try await self.loadUserData()
                        if self.currentUser?.username == nil {
                            let username = "AppleUser" + (self.userSession?.uid.prefix(5) ?? "00000")
                            await self.uploadUserData(uid: self.userSession?.uid ?? "", username: username, email: self.userSession?.email ?? "")
                        }
                    } catch {
                        print("Failed to load user data after Apple sign-in: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}
