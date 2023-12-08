import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct AddFriendView: View {
    @EnvironmentObject var viewModel: SocialViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                // Lazy VStack bc of the possibility of a lot of users here... Don't want them all to load
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(viewModel.users) { user in
                        if user != viewModel.user && searchText.isEmpty || user.username.contains(searchText)  {
                            NavigationLink(destination: FriendProfileView(focusedUser: user).environmentObject(viewModel)) {
                                HStack {
                                    ProfileImage(user: user, size: ProfileImageSize.xsmall)
                                    
                                    Text(user.username)
                                    
                                    // If the user is already friends...
                                    if let userFriends = viewModel.user.friends, userFriends.contains(user.id) {
                                        Spacer()
                                        Image(systemName: "person.fill.checkmark")
                                            .frame(width: 50, height: 50)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a friend")
        }
    }
}


