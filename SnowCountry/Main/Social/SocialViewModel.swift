import SwiftUI
import Foundation
import FirebaseFirestore

@MainActor
class SocialViewModel: ObservableObject {
    @Published var user: User
    @Published var users = [User]()
    @Published var invites: [User]? = nil
    @Published var posts = [Post]()

    init(user: User) {
        self.user = user

        Task {
            try await fetchPosts()
            try await fetchAllUsers()
            try await fetchInvites()
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
    
    @MainActor
    func fetchInvites() async throws {
        // Could user a mapping here probably but im hungry and I couldn't figure out the correct optional unwrapping
        if let invites = user.friendInvites {
            var tmpInvites = [User]()
            for invite in invites {
                try await tmpInvites.append(UserService.fetchUser(withUID: invite))
            }
            self.invites = tmpInvites
        }
    }
    
    // Add friend should add the focused users id to the current users "pending" array
    // And the current users id to the focused users invite array
    func sendFriendInvite(focusedUser: User) async throws {
        // Array could be empty here so use a data dict
        var data = [String: Any]()
        
        // Updates user object locally
        if var userFriendsPending = user.pendingFriends {
            userFriendsPending.append(focusedUser.id)
            data["pendingFriends"] = userFriendsPending
            user.pendingFriends = userFriendsPending
        } else {
            data["pendingFriends"] = [focusedUser.id]
            user.pendingFriends = [focusedUser.id]
        }
        
        try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        
        // Don't need to update the focused user object locally
        // but we should clear the data bc we need to switch documents
        data.removeAll()
        
        // This is more complicated than I thought
        // Need to grab the list of the focused user friend invites see if it exists and append to that
        if var focusedUserFriendInvites = focusedUser.friendInvites {
            focusedUserFriendInvites.append(user.id)
            data["friendInvites"] = focusedUserFriendInvites
            // Don't need to update locally
        } else {
            data["friendInvites"] = [user.id]
        }
        
        try await Firestore.firestore().collection("users").document(focusedUser.id).updateData(data)
        
        // Update the user object just in case
        let _ = try await AuthService.shared.loadUserData()
    }
    
    func removeFriend() async throws {
        
    }
    
    func confirmFriendInvite(focusedUser: User) async throws {
        var data = [String: Any]()

        // Remove pending invite from focused user
        if var pendingFriends = focusedUser.pendingFriends, var friendInvites = user.friendInvites {
            data["pendingFriends"] = pendingFriends.filter { $0 != user.id }
            data["friends"] = user.id
            try await Firestore.firestore().collection("users").document(focusedUser.id).updateData(data)
            
            data.removeAll()
            
            // Remove friend invite from current user
            let tmpFriendInvites = friendInvites.filter { $0 != focusedUser.id }
            data["friendInvites"] = tmpFriendInvites
            user.friendInvites = tmpFriendInvites
            Task { try await fetchInvites() }
            
            data["friends"] = focusedUser.id // Add current user id to focused user friend list and the opposite
            if var friends = user.friends {
                friends.append(focusedUser.id)
                user.friends = friends
            } else {
                user.friends = [focusedUser.id]
            }
            
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }
        
        let _ = try await AuthService.shared.loadUserData()
    }
    
    func cancelFriendInvite() async throws {
        
    }
}
