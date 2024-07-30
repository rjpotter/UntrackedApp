//
//  FriendRequestsView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/21/24.
//

import SwiftUI

struct FriendRequestsView: View {
    @ObservedObject var socialViewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss
    let user: User

    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all)

            VStack {
                // Header
                HStack {
                    Spacer()
                    Text("Friend Requests")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                .padding()

                // List of Friend Requests
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(socialViewModel.invites ?? [], id: \.id) { invite in
                            FriendRequestCard(socialViewModel: socialViewModel, invite: invite)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color("Base"))
        .onAppear {
            Task {
                try await socialViewModel.fetchInvites()
            }
        }
    }
}

struct FriendRequestCard: View {
    var socialViewModel: SocialViewModel
    var invite: User

    var body: some View {
        HStack {
            ProfileImage(user: invite, size: .medium)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 5) {
                Text(invite.username)
                    .font(.headline)
                    .foregroundColor(.primary)
                // Additional invite information
            }

            Spacer()

            Button(action: { Task { try? await socialViewModel.confirmFriendInvite(focusedUser: invite) } }) {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
            }

            Button(action: { Task { try? await socialViewModel.declineFriendInvite(inviteId: invite.id) } }) {
                Image(systemName: "x.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .font(.system(size: 40))
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(8)
    }
}

