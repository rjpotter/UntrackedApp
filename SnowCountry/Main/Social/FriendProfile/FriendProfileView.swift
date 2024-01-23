import SwiftUI
/*
struct FriendProfileView: View {
//    @StateObject var viewModel: FriendProfileViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: SocialViewModel
    let focusedUser: User
//    init(currentUser: User, focusedUser: User) {
//        self._viewModel = StateObject(wrappedValue: FriendProfileViewModel(currentUser: currentUser, focusedUser: focusedUser))
//    }
    
    var body: some View {
        VStack {            
            Text(focusedUser.username)
            
            // If the profile being viewed is not the current users friend...
            if let currentUserFriendPending = viewModel.user.pendingFriends,
                        currentUserFriendPending.contains(focusedUser.id) { // This person has a pending friend invite
                Button("Yeet Friend Invite") { // Revoke friend invite
                    Task { try await viewModel.cancelFriendInvite() }
                }
            } else if let currentUserFriends = viewModel.user.friends,
                      currentUserFriends.contains(focusedUser.id) {
                Button("Remove Friend") {
                    Task { try await viewModel.removeFriend() }
                }
            }  else {
                Button("Add Friend") {
                    Task { try await viewModel.sendFriendInvite(focusedUser: focusedUser) }
                }
            }
        }
    }
}
*/
