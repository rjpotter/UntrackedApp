import SwiftUI

struct SocialView: View {
    //
    //    @Environment(\.colorScheme) var colorScheme
    //    @ObservedObject private var viewModel = PostLogic()  // Assuming you have this ViewModel from earlier
    //    @State private var showingPostView = false
    //
    //    var body: some View {
    //        NavigationView {
    //            GeometryReader { geometry in
    //                List(viewModel.posts) { post in  // Use your view model's posts
    //                    PostView(post: post, width: geometry.size.width * 0.95)  // A separate view to display each post
    //                }
    //                .listStyle(.plain)
    //            }
    //            .navigationTitle("Social")
    //            .navigationBarItems(trailing: Button(action: {
    //                showingPostView.toggle()
    //            }, label: {
    //                Image(systemName: "plus")
    //            }))
    //            .navigationBarTitleDisplayMode(.inline)
    //            .sheet(isPresented: $showingPostView) {
    //                PostCreationView(viewModel: viewModel)  // Your view for creating a post
    //            }
    //        }
    //    }
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
                    NavigationLink(destination: AddFriendView().environmentObject(viewModel)) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal, 1)
                    
                    NavigationLink(destination: FriendInviteView().environmentObject(viewModel)) {
                        Image(systemName: "tray")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                    Button {
                        showUploadPhoto.toggle()
                    } label: {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 20))
                            .frame(width: 50, height: 60)
                    }
//                    NavigationLink(destination: UploadPostView().environmentObject(viewModel)) {
//
//                    }
                }
                .frame(height: 20)
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.posts) { post in
                            PostCell(post: post)
                        }
                    }
                    
                }
            }
            .background(Color("Background").opacity(0.5))
            .navigationTitle("Social Feed")
        }
    }
}
