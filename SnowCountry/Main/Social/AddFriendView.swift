import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    @StateObject var viewModel: AddFriendViewModel
    //    @State var password = ""
    //    @State var email = ""
    
    // This could probably be a let user: User instead
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: AddFriendViewModel(user: user))
        print("asdasd")
    }
    
    var body: some View {
        VStack {
            
            ScrollView {
                // Lazy VStack bc of the possibility of a lot of users here... Don't want them all to load
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(viewModel.users) { user in
                        if user != viewModel.user && searchText.isEmpty || user.username.contains(searchText)  {
                            NavigationLink(destination: FriendProfileView(currentUser: viewModel.user, focusedUser: user)) {
                                HStack {
                                    ProfileImage(user: user, size: ProfileImageSize.xsmall)
                                    
                                    Text(user.username)
                                    
                                    if let userFriends = viewModel.user.friends, userFriends.contains(user.id) {
                                        Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            
                        }
                    }
                }
                
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a friend")
            .navigationTitle("Find Friends")
            .navigationBarTitleDisplayMode(.inline)
            //            .navigationDestination(for: User.self, destination: { user in
            //                FriendProfileView(currentUser: viewModel.user, focusedUser: user) // Pass in the user here
            //            })
            
        }
        
    }
        
}


