//
//  FriendsListView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/21/23.
//

import SwiftUI

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel
    @Binding var selectedIndex: Int
    @State private var showAlert = false
    @State private var navigateToAddFriend = false
    
    init(user: User, selectedIndex: Binding<Int>) {
        self._viewModel = StateObject(wrappedValue: SocialViewModel(user: user))
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("SnowCountry")
                        .font(Font.custom("Good Times", size: 30))
                        .padding(.top)
                    HStack {
                        Button(action: {
                            navigateToAddFriend = true // Set state to true to navigate
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.green)
                                .cornerRadius(10)
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
                    
                    NavigationLink(destination: AddFriendView().environmentObject(viewModel), isActive: $navigateToAddFriend) {
                        EmptyView() // Hidden NavigationLink
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.posts) { post in
                                PostCell(post: post).environmentObject(viewModel)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
}
