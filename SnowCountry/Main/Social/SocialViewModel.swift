import SwiftUI
import Foundation
import FirebaseFirestore

@MainActor
class SocialViewModel: ObservableObject {
    @Published var user: User
    @Published var users = [User]()
    @Published var posts = [Post]()

    init(user: User) {
        self.user = user

        Task {
            try await fetchPosts()
            try await fetchAllUsers()
        }
    }
    
    @MainActor
    func fetchPosts() async throws {
        self.posts = try await PostService.fetchAllPosts()
    }
    
    @MainActor
    func fetchAllUsers() async throws {
        self.users = try await UserService.fetchAllUsers()
    }
    
    // Add friend should add the focused users id to the current users "pending" array
    // And the current users id to the focused users invite array
    func sendFriendInvite(focusedUser: User) async throws {
        // Array could be empty here so use a data dict
        var data = [String: Any]()
        
        // Updates user object locally
        if var userFriendsPending = user.friendsPending {
            userFriendsPending.append(focusedUser.id)
            data["friendsPending"] = userFriendsPending
            user.friendsPending = userFriendsPending
        } else {
            data["friendsPending"] = [focusedUser.id]
            user.friendsPending = [focusedUser.id]
        }
        
        try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        
        // Don't need to update the focused user object locally
        // but we should clear the data bc we need to switch documents
        data.removeAll()
        data["friendsInvite"] = user.id
        try await Firestore.firestore().collection("users").document(focusedUser.id).updateData(data)
        

        
//        // If user doesn't have any friend this array will be nil
//        if var currentUserFriends = currentUser.friends {
//            currentUserFriends.append(focusedUser.id)
//            data["friends"] = currentUserFriends
//            currentUser.friends = currentUserFriends
//        } else {
//            data["friends"] = [focusedUser.id]
//            currentUser.friends = [focusedUser.id]
//        }
//
//        if !data.isEmpty {
//            try await Firestore.firestore().collection("users").document(currentUser.id).updateData(data)
//        }
        
        // Update the user object just in case
        let _ = try await AuthService.shared.loadUserData()
    }
    
    func removeFriend() async throws {
        
    }
    
    func confirmFriendInvite() async throws {
        
    }
    
    func cancelFriendInvite() async throws {
        
    }
}
