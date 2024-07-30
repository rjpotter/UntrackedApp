//
//  SocialView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/11/23.
//

import SwiftUI

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedIndex: Int
    @State private var showAlert = false
    @State private var navigateToAddFriend = false
    @State private var navigateToUploadPost = false
    @State private var navigateBackToRoot = false
    @State private var isRefreshing = false

    init(user: User, selectedIndex: Binding<Int>) {
        self._viewModel = StateObject(wrappedValue: SocialViewModel(user: user))
        self._selectedIndex = selectedIndex
        self.locationManager = LocationManager()
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("Untracked")
                        .font(Font.custom("Good Times", size: 30))
                    HStack {
                        Button(action: {
                            navigateToAddFriend = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(22)
                        }

                        Spacer()

                        Button(action: {
                            // Action for heart button (liked posts) goes here
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(22)
                        }

                        Button(action: {
                            navigateToUploadPost = true
                        }) {
                            Image(systemName: "plus.square")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(.orange)
                                .cornerRadius(22)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    NavigationLink(destination: AddFriendView().environmentObject(viewModel), isActive: $navigateToAddFriend) {
                        EmptyView() // Hidden NavigationLink
                    }

                    .fullScreenCover(isPresented: $navigateToUploadPost) {
                        TrackHistoryListView(socialViewModel: viewModel, fromSocialPage: true, locationManager: locationManager, isMetric: .constant(false), navigateBackToRoot: $navigateBackToRoot)
                    }

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.posts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })) { post in
                                PostCell(post: post).environmentObject(viewModel)
                            }
                        }
                    }
                    .refreshable {
                        await refresh()
                    }
                }
            }
            .background(Color("Base"))
            .onChange(of: navigateBackToRoot) { newValue in
                if newValue {
                    navigateToUploadPost = false
                    navigateBackToRoot = false
                }
            }
        }
    }

    private func refresh() async {
        isRefreshing = true
        do {
            try await viewModel.fetchPosts()
        } catch {
            print("Error fetching posts: \(error)")
            // Handle error appropriately, maybe show an alert to the user
        }
        isRefreshing = false
    }
}

struct SocialView_Previews: PreviewProvider {
    @State static var selectedIndex = 0

    static var previews: some View {
        // Create a mock user
        let mockUser = User(id: "mockUserID", username: "RPotts115", email: "mockuser@example.com")
        
        // Create a mock SocialViewModel with the mock user
        let mockViewModel = SocialViewModel(user: mockUser)
        
        return SocialView(user: mockUser, selectedIndex: .constant(selectedIndex))
            .environmentObject(mockViewModel)
            .previewLayout(.sizeThatFits)
    }
}

