import SwiftUI

struct FriendProfileView: View {
    @StateObject var viewModel: FriendProfileViewModel
    //var onDismiss: ((User) -> Void)?
    @Environment(\.dismiss) var dismiss
//    @Binding var tabIndex: Int
    
    init(currentUser: User, focusedUser: User) {
        self._viewModel = StateObject(wrappedValue: FriendProfileViewModel(currentUser: currentUser, focusedUser: focusedUser))
//        self._tabIndex = tabIndex
    }
    
    var body: some View {
        VStack {
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            // Even though user is updated through combine, the navigation stack doesn't update its user object until going all the way back to the og parent
            HStack {
            NavigationLink("Go back", destination: AddFriendView(user: viewModel.currentUser))
            }
        )
    }
}

//struct FriendProfileView: View {
//    let user: User
//
//    var body: some view {
//        Text(user.username)
//    }
//}
