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
    @StateObject var viewModel = SocialViewModel()
    @State private var showAddFriend = false
    let user: User
//    @Binding var tabIndex: Int
    
    var body: some View {
        VStack {
            NavigationStack {
                HStack {
                    NavigationLink(destination: AddFriendView(user: user)) {
                        Image(systemName: "person.badge.plus")
                            .frame(width: 90, height: 90)
                    }
                    Spacer()
                    NavigationLink(destination: UploadPostView(user: user)) {
                        Image(systemName: "photo.stack")
                            .frame(width: 90, height: 90)
                    }
                }
            }
            .frame(height: 40)
            
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.posts) { post in
                            PostCell(post: post)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
