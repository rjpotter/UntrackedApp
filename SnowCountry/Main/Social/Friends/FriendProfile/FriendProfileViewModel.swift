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
    
    // Add friend should add the focused users id to the current users "pending" array
    // And the current users id to the focused users invite array
//    func addFriend() async throws {
//        var data = [String: Any]()
//
//        if var currentUserFriendsPending = currentUser.friendsPending {
//            currentUserFriendsPending.append(focusedUser.id)
//            data["friendsPending"] = currentUserFriendsPending
//            currentUser.friendsPending = currentUserFriendsPending
//        } else {
//            data["friendsPending"] = [focusedUser.id]
//            currentUser.friendsPending = [focusedUser.id]
//        }
//
//        try await Firestore.firestore().collection("users").document(currentUser.id).updateData(data)
//
//        data.removeAll()
//
//        if var focusedUserFriendsInvite = focusedUser.friendsInvite {
//            focusedUserFriendsInvite.append(currentUser.id)
//            data["friendsInvite"] = focusedUserFriendsInvite
//            focusedUser.friendInvites = focusedUserFriendsInvite
//        } else {
//            data["friendsInvite"] = [currentUser.id]
//            currentUser.pendingFriends = [currentUser.id]
//        }
//
//        try await Firestore.firestore().collection("users").document(focusedUser.id).updateData(data)
//
//
////        // If user doesn't have any friend this array will be nil
////        if var currentUserFriends = currentUser.friends {
////            currentUserFriends.append(focusedUser.id)
////            data["friends"] = currentUserFriends
////            currentUser.friends = currentUserFriends
////        } else {
////            data["friends"] = [focusedUser.id]
////            currentUser.friends = [focusedUser.id]
////        }
////
////        if !data.isEmpty {
////            try await Firestore.firestore().collection("users").document(currentUser.id).updateData(data)
////        }
//
//        let _ = try await AuthService.shared.loadUserData()
//    }
    
    
}
