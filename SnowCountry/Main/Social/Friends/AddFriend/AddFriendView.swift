import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct AddFriendView: View {
    @EnvironmentObject var viewModel: SocialViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var isMetric = false

    var body: some View {
        VStack {
            Text("Add Friends")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            // User list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(filteredUsers(), id: \.self) { user in
                        NavigationLink(destination: FriendProfileView(forFriend: user, isMetric: $isMetric, locationManager: locationManager, userSettings: userSettings)) {
                            UserCard(user: user, viewModel: viewModel)
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
        return viewModel.users.filter { $0 != viewModel.user && (searchText.isEmpty || $0.username.lowercased().contains(lowercasedSearchText)) }
    }
}

struct UserCard: View {
    var user: User
    @ObservedObject var viewModel: SocialViewModel
    @State private var requestSent = false

    var body: some View {
        HStack {
            ProfileImage(user: user, size: .medium)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))

            VStack(alignment: .leading, spacing: 5) {
                Text(user.username)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Spacer()
            if requestSent || viewModel.hasSentFriendInvite(to: user) {
                Button(action: {
                    Task {
                        try await viewModel.cancelFriendInvite(focusedUser: user)  
                        requestSent = false
                    }
                }) {
                    Text("Requested")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            } else if let userFriends = viewModel.user.friends, userFriends.contains(user.id) {
                Button(action: {
                    Task {
                        try await viewModel.removeFriend(focusedUser: user)
                    }
                }) {
                    Text("Following")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    Task {
                        try await viewModel.sendFriendInvite(focusedUser: user)
                        requestSent = true
                    }
                }) {
                    Text("Follow")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color("Base"))
        .cornerRadius(8)
    }
}
