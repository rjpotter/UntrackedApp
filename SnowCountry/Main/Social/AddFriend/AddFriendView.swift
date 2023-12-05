import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
//    @Binding var tabIndex: Int
    @StateObject var viewModel: AddFriendViewModel
    @State private var showFriendProfile = false
    @State var focUser: User?
    //    @State var password = ""
    //    @State var email = ""
    
    // This could probably be a let user: User instead
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: AddFriendViewModel(user: user))
//        self._tabIndex = tabIndex
    }
    
    var body: some View {
        VStack {
            // Tool bar
            HStack {
                Button {
                    dismiss()
//                    tabIndex = 0
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                
                Text("Add a friend")
                
                Spacer()
            }
            NavigationStack {
                ScrollView {
                    // Lazy VStack bc of the possibility of a lot of users here... Don't want them all to load
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(viewModel.users) { user in
                            if user != viewModel.user && searchText.isEmpty || user.username.contains(searchText)  {
                                //.
//                                Button {
//                                    focUser = user
//                                    showFriendProfile.toggle()
//                                    print(focUser)
//                                } label: {
//                                    HStack {
//                                        ProfileImage(user: user, size: ProfileImageSize.xsmall)
//
//                                        Text(user.username)
//
//                                        if let userFriends = viewModel.user.friends, userFriends.contains(user.id) {
//                                            Image(systemName: "person.fill.checkmark")
//                                                .resizable()
//                                                .frame(width: 30, height: 30)
//                                        }
//                                    }
//                                    .padding(.horizontal)
//                                }
                                NavigationLink(destination: FriendProfileView(currentUser: viewModel.user, focusedUser: user)) {
                                    HStack {
                                        ProfileImage(user: user, size: ProfileImageSize.xsmall)

                                        Text(user.username)

                                        if let userFriends = viewModel.user.friends, userFriends.contains(user.id) {
                                            Image(systemName: "person.fill.checkmark")
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
            }
            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading:
//                // Navigation header
//                HStack {
//                    NavigationLink("Go back", destination: SocialView(user: viewModel.user))
//                    Button("back") {
//                        tabIndex = 0
//                    }
//                }
//            )
//            .navigationTitle("Find Friends")
//            .navigationBarTitleDisplayMode(.inline)
            //            .navigationDestination(for: User.self, destination: { user in
            //                FriendProfileView(currentUser: viewModel.user, focusedUser: user) // Pass in the user here
            //            })
            
        }
//        .fullScreenCover(isPresented: $showFriendProfile) {
//            if let fUser = focUser {
//                FriendProfileView(currentUser: viewModel.user, focusedUser: fUser)
//            }
//        }
    }
    
}


