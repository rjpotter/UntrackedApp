import SwiftUI

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel
    @State private var showAddFriend = false
    @State private var showUploadPhoto = false
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: SocialViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            Text("SnowCountry")
                .font(Font.custom("Good Times", size:30))
            
            NavigationStack {
                HStack {
                    NavigationLink(destination: FriendsView().environmentObject(viewModel)) {
                        Image(systemName: "person")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 50)
                    }
                    
                    NavigationLink(destination: AddFriendView().environmentObject(viewModel)) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 50)
                    }
                    
                    NavigationLink(destination: FriendInviteView().environmentObject(viewModel)) {
                        Image(systemName: "tray")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: UploadPostView(user: viewModel.user)) {
                        Image(systemName: "plus.square")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 50)

                    }
                }
                .frame(height: 30)
                .background(Color("Background").opacity(0.5))
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.posts) { post in
                            PostCell(post: post).environmentObject(viewModel)
                        }
                    }
                    
                }
            }
            .background(Color("Background").opacity(0.5))
            .navigationTitle("Social Feed")
        }
        .background(Color("Background").opacity(0.5))
    }
}
