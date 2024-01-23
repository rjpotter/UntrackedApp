//
//  FriendsListView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/21/23.
//

import SwiftUI

enum ActiveSheetTwo: Identifiable {
    case friends
    case friendRequests
    case addFriends

    var id: Int {
        hashValue
    }
}

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel
    @Binding var selectedIndex: Int
    @State private var showAlert = false
    @State private var activeSheetTwo: ActiveSheetTwo?
    
    init(user: User, selectedIndex: Binding<Int>) {
        self._viewModel = StateObject(wrappedValue: SocialViewModel(user: user))
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("SnowCountry")
                    .font(Font.custom("Good Times", size: 30))
                    .padding(.top)
                HStack {
                    Button(action: {
                        activeSheetTwo = .friends
                    }) {
                        Image(systemName: "person")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        activeSheetTwo = .addFriends
                    }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        activeSheetTwo = .friendRequests
                    }) {
                        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                            Image(systemName: "tray")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.orange)
                                .cornerRadius(10)
                            
                            // Conditionally display a red dot if there are invites
                            if let invites = viewModel.invites, !invites.isEmpty {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 15, height: 15)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Actions to perform when this button is tapped
                        // Currently left empty to make the button non-functional
                        //NavigationLink(destination: UploadPostView(user: viewModel.user)) {
                    }) {
                        Image(systemName: "plus.square")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 2)
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.posts) { post in
                            PostCell(post: post).environmentObject(viewModel)
                        }
                    }
                }
            }
            .sheet(item: $activeSheetTwo) { item in
                switch item {
                case .friends:
                    FriendsListView(socialViewModel: viewModel, user: viewModel.user) // use 'viewModel' and 'viewModel.user'
                case .friendRequests:
                    FriendRequestsView(socialViewModel: viewModel, user: viewModel.user) // use 'viewModel' and 'viewModel.user'
                case .addFriends:
                    AddFriendView()
                        .environmentObject(viewModel)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}
