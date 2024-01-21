//
//  FriendsListView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/21/24.
//

import SwiftUI

struct FriendsListView: View {
    @ObservedObject var socialViewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss
    let user: User

    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all) // Supports dark mode

            VStack {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrowshape.backward")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }
                    Spacer()
                    Text("Friends")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                .padding()

                // List of Friends
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(socialViewModel.friends ?? [], id: \.id) { friend in
                            FriendCard(socialViewModel: socialViewModel, friend: friend, action: {
                                // Action to navigate to friend's profile
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            Task {
                try await socialViewModel.fetchFriends()
            }
        }
    }
}

struct FriendCard: View {
    var socialViewModel: SocialViewModel
    var friend: User
    var action: () -> Void

    var body: some View {
        HStack {
            ProfileImage(user: friend, size: .medium)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 5) {
                Text(friend.username)
                    .font(.headline)
                    .foregroundColor(.primary)
                // Additional friend information
            }

            Spacer()
            // Determine the appropriate button based on friendship status
            if socialViewModel.isFollowing(friend: friend) {
                // If already friends
                Button(action: {
                        // Remove Friend Action
                    }) {
                    Text("Following")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
            } else {
                // If not friends yet
                Button(action: { Task { try? await socialViewModel.sendFriendInvite(focusedUser: friend) } }) {
                    Text("Follow")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(8)
    }
}
