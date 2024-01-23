//
//  FriendsListView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/21/23.
//


import SwiftUI
import Kingfisher

struct PostCell: View {
    @EnvironmentObject var viewModel: SocialViewModel
    let post: Post
    
    var body: some View {
        VStack {
            if let user = post.user {
                HStack(alignment: .center) {
                    ProfileImage(user: user, size: ProfileImageSize.medium)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(timestampFormatted(post.timestamp.dateValue()))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
            
            if let imageURL = post.imageURL {
                KFImage(URL(string: imageURL))
                    .resizable()
                    .scaledToFit()
                    .clipShape(Rectangle())
                    .padding(.vertical, 8)
            }
            
            HStack {
                Text(String(post.likes))
                
                Button(action: {
                    // Toggle like/unlike
                    if let likedPosts = viewModel.user.likedPosts, likedPosts.contains(post.id) {
                        Task { try await viewModel.unLikePost(uid: post.id) }
                    } else {
                        Task { try await viewModel.likePost(uid: post.id) }
                    }
                }) {
                    Image(systemName: viewModel.user.likedPosts?.contains(post.id) ?? false ? "snowflake.circle.fill" : "snowflake")
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack {
                if let user = post.user {
                    Text(user.username)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                Text(post.caption)
                    .font(.subheadline)
                    .lineLimit(nil)
                
                Spacer()
            }
            .frame(maxWidth: (UIScreen.main.bounds.width - 20))
        }
        .cornerRadius(10)
        .padding(.vertical)
    }
    
    // Format timestamp to a user-friendly string
    private func timestampFormatted(_ timestamp: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: timestamp)
    }
}
