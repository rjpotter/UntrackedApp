//
//  PostCell.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/21/23.
//


import SwiftUI
import Firebase
import FirebaseAuth
import Kingfisher

struct PostCell: View {
    @EnvironmentObject var viewModel: SocialViewModel
    @State private var isFullScreen: Bool = false
    @State private var selectedIndex: Int = 0
    let post: Post
    @State private var showDeleteAlert = false

    var body: some View {
        VStack {
            if let user = post.user {
                HStack(alignment: .center) {
                    NavigationLink(destination: userProfileDestination(user: user)) {
                        ProfileImage(user: user, size: .medium)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.username)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(timestampFormatted(post.timestamp.dateValue()))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            // Display stoke level
                            if let stokeLevel = post.stokeLevel {
                                HStack(spacing: 4) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: "snowflake")
                                            .foregroundColor(index < stokeLevel ? .blue : .gray)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if viewModel.user.id == post.ownerUID {
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "ellipsis")
                        }
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Post"),
                                message: Text("Are you sure you want to delete this post?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    deletePost()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Display tagged users
            if let taggedUsers = post.taggedUsers, !taggedUsers.isEmpty {
                HStack {
                    Text("Tagged (\(taggedUsers.count)):")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(taggedUsers, id: \.id) { taggedUser in
                                NavigationLink(destination: userProfileDestination(user: taggedUser)) {
                                    TaggedCard(user: taggedUser)
                                        .padding(.horizontal, 5)
                                }
                            }
                        }
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
                } else {
                    CollageViewURL(imageURLs: imageURLs)
                        .onTapGesture {
                            isFullScreen = true
                        }
                }
            } else if let imageURL = post.imageURL, let url = URL(string: imageURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Rectangle())
            }

            // Likes and other post details
            HStack {
                Text(String(post.likes))
                    .font(.headline) // Set the desired font size
                
                Button(action: {
                    if let likedPosts = viewModel.user.likedPosts, likedPosts.contains(post.id) {
                        Task { try await viewModel.unLikePost(postId: post.id) }
                    } else {
                        Task { try await viewModel.likePost(postId: post.id) }
                    }
                }) {
                    if let likedPosts = viewModel.user.likedPosts, likedPosts.contains(post.id) {
                        ZStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                            Image(systemName: "snowflake")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gray)
                    }
                }
                
                Text("0")
                    .font(.headline) // Set the desired font size
                
                Button(action: {
                    // Your message button action here
                }) {
                    Image(systemName: "message")
                        .resizable()
                        .frame(width: 25, height: 25) // Set the desired size
                        .foregroundColor(.gray)
                }
                
                Spacer() // Add space to push content to the left
            }
            .padding(.horizontal) // Add horizontal padding
            .padding(.leading, 5)
            .padding(.vertical, 2)
            
            HStack(alignment: .top, spacing: 4) {
                if let user = post.user {
                    NavigationLink(destination: userProfileDestination(user: user)) {
                        HStack(spacing: 4) {
                            ProfileImage(user: user, size: .micro)
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                            
                            Text(user.username)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // Remove default styling
                    
                    Text(" \(post.caption)")
                        .font(.subheadline)
                } else {
                    Text(post.caption)
                        .font(.subheadline)
                }
                Spacer()
            }
            .frame(maxWidth: (UIScreen.main.bounds.width - 20))
        }
        .cornerRadius(10)
        .padding(.vertical)
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenImageViewURL(imageURLs: post.imageURLs ?? [], selectedIndex: $selectedIndex, isPresented: $isFullScreen)
        }
    }
    
    // Destination View for user profiles
    @ViewBuilder
    private func userProfileDestination(user: User) -> some View {
        if user.id == Auth.auth().currentUser?.uid {
            ProfileView(user: user) // Navigate to your profile, ensure the correct initializer is called
        } else {
            FriendProfileView(forFriend: user, isMetric: .constant(true), locationManager: LocationManager(), userSettings: UserSettings())
        }
    }
    
    // Format timestamp to a user-friendly string
    private func timestampFormatted(_ timestamp: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: timestamp)
    }
    
    func deletePost() {
        guard viewModel.user.id == post.ownerUID else {
            // Optionally, handle the case where the user is not the owner
            return
        }

        Task {
            do {
                try await viewModel.deletePost(postId: post.id)
            } catch {
                print("Failed to delete post: \(error)")
            }
        }
    }
}

struct TaggedCard: View {
    var user: User
    
    var body: some View {
        HStack {
            ProfileImage(user: user, size: .micro)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1))
            
            Text(user.username)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(5)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(6)
    }
}

