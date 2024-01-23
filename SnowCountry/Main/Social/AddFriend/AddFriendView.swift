import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct AddFriendView: View {
    @EnvironmentObject var viewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all)

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
                    Text("Add Friends")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                .padding()

                // In AddFriendView
                ScrollView{
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(viewModel.users) { user in
                            if user != viewModel.user && (searchText.isEmpty || user.username.contains(searchText)) {
                                UserCard(user: user, viewModel: viewModel)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a friend")
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
                .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 5) {
                Text(user.username)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Spacer()
            if requestSent || viewModel.hasSentFriendInvite(to: user) {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.cancelFriendInvite(focusedUser: user)
                            requestSent = false
                        } catch {
                            print("Error cancelling friend request: \(error)")
                        }
                    }
                }) {
                    Image(systemName: "person.badge.clock")
                        .foregroundColor(.orange)
                        .font(.system(size: 40))
                        .frame(width: 40, height: 40)
                }
            } else if let userFriends = viewModel.user.friends, userFriends.contains(user.id) {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.removeFriend(focusedUser: user)
                        } catch {
                            print("Error removing friend: \(error)")
                        }
                    }
                }) {
                    Image(systemName: "person.fill.checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 40))
                        .frame(width: 40, height: 40)
                }
            } else {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.sendFriendInvite(focusedUser: user)
                            requestSent = true
                        } catch {
                            print("Error sending friend request: \(error)")
                        }
                    }
                }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                        .frame(width: 40, height: 40)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(8)
    }
}
