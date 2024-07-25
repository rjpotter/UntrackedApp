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

            // User list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(filteredUsers(), id: \.self) { user in
                        NavigationLink(destination: FriendProfileView(forFriend: user, isMetric: $isMetric, locationManager: locationManager, userSettings: userSettings)) {
                            UserCard(user: user, viewModel: socialViewModel)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a friend")
    }

    private func filteredUsers() -> [User] {
        /* To have the search be empty until a user starts typing
         if searchText.isEmpty {
         return []
         } else {
         let lowercasedSearchText = searchText.lowercased()
         return viewModel.users.filter { $0 != viewModel.user && $0.username.lowercased().contains(lowercasedSearchText) }
         }
         */
        // Make every user visible
        let lowercasedSearchText = searchText.lowercased()
        return (socialViewModel.friends ?? []).filter {
            // Compare $0 with the current user (socialViewModel.user)
            $0 != socialViewModel.user &&
            (searchText.isEmpty || $0.username.lowercased().contains(lowercasedSearchText))
        }
    }
}
