//
//  PostCell.swift
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
                .padding(.horizontal)
            }

            // Display images
            if let imageURLs = post.imageURLs, !imageURLs.isEmpty {
                if imageURLs.count == 1, let url = URL(string: imageURLs.first!) {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Rectangle())
                        .padding(.vertical, 8)
                } else {
                    CollageView(images: loadImages(from: imageURLs))
                        .padding(.vertical, 8)
                }
            } else if let imageURL = post.imageURL, let url = URL(string: imageURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Rectangle())
                    .padding(.vertical, 8)
            }

            // Likes and other post details
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

    // Load images from URLs
    private func loadImages(from urls: [String]) -> [UIImage] {
        return urls.compactMap { url -> UIImage? in
            guard let imageURL = URL(string: url), let data = try? Data(contentsOf: imageURL) else {
                return nil
            }
            return UIImage(data: data)
        }
    }
    
    // Format timestamp to a user-friendly string
    private func timestampFormatted(_ timestamp: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: timestamp)
    }
}
