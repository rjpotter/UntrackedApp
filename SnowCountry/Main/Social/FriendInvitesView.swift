/*
import SwiftUI

struct FriendInviteView: View {
    @EnvironmentObject var viewModel: SocialViewModel
    
    var body: some View {
        VStack {
            if let invites = viewModel.invites, !invites.isEmpty {
                // Lazy VStack bc of the possibility of a lot of users here... Don't want them all to load
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(invites) { user in
                        NavigationLink(destination: FriendProfileView(focusedUser: user).environmentObject(viewModel)) {
                            
                            HStack {
                                ProfileImage(user: user, size: ProfileImageSize.xsmall)
                                
                                Text(user.username)
                                
                                // If the user is already friends...
                                if let userFriends = viewModel.user.friends, userFriends.contains(user.id) {
                                    Image(systemName: "person.fill.checkmark")
                                        .frame(width: 30, height: 30)
                                }
                                
                                Spacer()
                                
                                Button {
                                    Task { try await viewModel.confirmFriendInvite(focusedUser: user) }
                                } label: {
                                    Image(systemName: "plus.circle")
                                }
                                Button {
                                    print("asd")
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                }
            } else {
                Text("No invites at the moment")
            }
        }
    }
}
*/
