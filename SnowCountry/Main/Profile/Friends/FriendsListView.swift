//
//  FriendsListView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/21/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct FriendsListView: View {
    @EnvironmentObject var socialViewModel: SocialViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State var isMetric: Bool
    @State var user: User

    var body: some View {
        VStack {
            Text("Friends")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(filteredUsers(), id: \.self) { friend in
                        NavigationLink(destination: FriendProfileView(forFriend: friend, isMetric: $isMetric, locationManager: locationManager, userSettings: userSettings)) {
                            UserCard(user: friend, viewModel: socialViewModel)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a friend")
        .onAppear {
            // Ensure friends are fetched when the view appears
            Task {
                try await socialViewModel.fetchFriends()
            }
        }
        .background(Color("Base"))
    }

    private func filteredUsers() -> [User] {
        let lowercasedSearchText = searchText.lowercased()
        return (socialViewModel.friends ?? []).filter {
            $0 != socialViewModel.user &&
            (searchText.isEmpty || $0.username.lowercased().contains(lowercasedSearchText))
        }
    }
}
