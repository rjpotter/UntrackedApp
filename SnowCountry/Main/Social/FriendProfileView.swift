import SwiftUI

struct FriendProfileView: View {
    @StateObject var viewModel: FriendProfileViewModel
    
    init(currentUser: User, focusedUser: User) {
        self._viewModel = StateObject(wrappedValue: FriendProfileViewModel(currentUser: currentUser, focusedUser: focusedUser))
    }
    
    var body: some View {
        Text(viewModel.focusedUser.username)
        
        // If the profile being viewed is not the current users friend...
        if let currentUserFriends = viewModel.currentUser.friends, currentUserFriends.contains(viewModel.focusedUser.id) {
            Button("Remove Friend") {
                Task { try await viewModel.removeFriend() }
            }
        } else { // Friend list is not yet initialized
            Button("Add Friend") {
                Task { try await viewModel.addFriend() }
            }
        }
    }
}

//struct FriendProfileView: View {
//    let user: User
//
//    var body: some view {
//        Text(user.username)
//    }
//}
