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
    
    @State private var showAddFriend = false
    let user: User
    
    var body: some View {
        VStack {
            Button("Add friend") {
                showAddFriend = true
            }
        }
        .fullScreenCover(isPresented: $showAddFriend) {
            AddFriendView(user: user)
        }
        
    }
}
