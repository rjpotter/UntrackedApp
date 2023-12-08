import SwiftUI
import Kingfisher
import Foundation

struct PostCell: View {
    @EnvironmentObject var viewModel: SocialViewModel
    let post: Post
    
    var body: some View{
        VStack{
            VStack(alignment: .leading, spacing: 0) {
                if let user = post.user {
                    HStack {
                        ProfileImage(user: user, size: ProfileImageSize.xsmall)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 4)
                            .padding(8)
                        
                        
                        Text(user.username)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                    }
                    .padding(.vertical, 4)
                    
                }
                
                if let imageURL = post.imageURL  {
                    KFImage(URL(string: imageURL))
                        .resizable()
                        .scaledToFit()
                        .clipShape(Rectangle())
                        .padding(.bottom, 8)
                }
                
                
                HStack {
                    Text(String(post.likes))
                    
                    if let likedPosts = viewModel.user.likedPosts, likedPosts.contains(post.id) {
                        Button {
                            // Increment post likes, this will require some thought
                            Task { try await viewModel.unLikePost(uid: post.id) }
                        } label: {
                            Image(systemName: "snowflake.circle.fill")
                        }
                    } else {
                        Button {
                            // Increment post likes, this will require some thought
                            Task { try await viewModel.likePost(uid: post.id) }
                        } label: {
                            Image(systemName: "snowflake")
                        }
                    }
                    
                    Spacer()
                    // Trying to add a date to the post here
                    // Seems like only the seconds and nano seconds of the post are being correctly imported from firebase
                    // Event though the date looks ok in firebase
                    // Maybe have the user set the date in upload post?
//                    let dateFormatter = DateFormatter()
//                    Text(dateFormatter.string(from: post.timestamp.dateValue()))
                }
                .padding(.horizontal)
                
                if let user = post.user {
                    HStack{
                        // Add the caption below the image
                        Text(user.username)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 2)
                            .padding(.bottom, 2)
                            .padding(.leading, 5)
                        
                        Text(post.caption)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .padding(.bottom, 2)
                            .lineLimit(nil)
                    }
                }
            }
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
            )
            .padding(.horizontal, -2)
            .background(Color("Base"))
            .shadow(radius: 5)
        }
    }
    
}
