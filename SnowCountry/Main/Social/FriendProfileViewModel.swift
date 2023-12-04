import SwiftUI
import FirebaseFirestore

@MainActor
class FriendProfileViewModel: ObservableObject {
    @Published var currentUser: User
    @Published var focusedUser: User // The user whose profile we are viewing
    
    init(currentUser: User, focusedUser: User) {
        self.currentUser = currentUser
        self.focusedUser = focusedUser
    }
    
    func addFriend() async throws {
        var data = [String: Any]()

        if var currentUserFriends = currentUser.friends {
            currentUserFriends.append(focusedUser.id)
            data["friends"] = currentUserFriends
            currentUser.friends = currentUserFriends
        } else {
            data["friends"] = [focusedUser.id]
            currentUser.friends = [focusedUser.id]
        }
                
        if !data.isEmpty {
            try await Firestore.firestore().collection("users").document(currentUser.id).updateData(data)
        }
        
        let _ = try await AuthService.shared.loadUserData()
    }
    
    func removeFriend() async throws {
        
    }
}
