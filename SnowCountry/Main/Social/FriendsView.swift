import SwiftUI
/*
struct FriendsView: View {
    @EnvironmentObject var viewModel: SocialViewModel
    
    var body: some View {
        VStack {
            if let friends = viewModel.friends, !friends.isEmpty {
                // Lazy VStack bc of the possibility of a lot of users here... Don't want them all to load
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(friends) { user in
                        NavigationLink(destination: FriendProfileView(focusedUser: user).environmentObject(viewModel)) {
                            
                            HStack {
                                ProfileImage(user: user, size: ProfileImageSize.xsmall)
                                
                                Text(user.username)
                                
                                Spacer()
                                
                                Button {
                                    print("Remove Friend")
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            } else {
                Text("You have no friends lol")
            }
        }
    }
}
*/
