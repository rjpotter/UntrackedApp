//
//  TagPeopleView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/25/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct TagPeopleView: View {
    @EnvironmentObject var socialViewModel: SocialViewModel
    @EnvironmentObject var userSettings: UserSettings
    @Binding var selectedFriends: [User]
    @State private var searchText: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSearching: Bool = false

    private let maxSelectableFriends = 10

    var body: some View {
        VStack {
            Text("Tag Friends")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            // Search bar
            TextField("Search for a user", text: $searchText, onEditingChanged: { isEditing in
                isSearching = isEditing || !searchText.isEmpty
            })
            .padding(10)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)

            // Display selected friends' usernames and count
            if !selectedFriends.isEmpty {
                HStack {
                    Text("Selected: \(selectedFriends.count)/\(maxSelectableFriends)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedFriends, id: \.id) { friend in
                                MicroFriendCard(user: friend)
                                    .padding(.horizontal, 5)
                                    .padding(.bottom, 10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            if !searchText.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(filteredUsers(), id: \.self) { user in
                            FriendCard(user: user, selected: selectedFriends.contains(user))
                                .onTapGesture {
                                    toggleSelection(for: user)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            } else if let friends = socialViewModel.friends, !friends.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(filteredFriends(), id: \.self) { friend in
                            FriendCard(user: friend, selected: selectedFriends.contains(friend))
                                .onTapGesture {
                                    toggleSelection(for: friend)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No friends available to tag.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle("Tag People")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Limit Reached"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            // Ensure all users are loaded for search
            Task {
                do {
                    try await socialViewModel.fetchFriends()
                    print("Fetched friends: \(socialViewModel.friends?.map { $0.username } ?? [])")
                } catch {
                    print("Error fetching friends: \(error)")
                }
            }
        }
    }

    private func filteredFriends() -> [User] {
        let lowercasedSearchText = searchText.lowercased()
        return (socialViewModel.friends ?? []).filter {
            $0 != socialViewModel.user &&
            (searchText.isEmpty || $0.username.lowercased().contains(lowercasedSearchText))
        }
    }

    private func filteredUsers() -> [User] {
        let lowercasedSearchText = searchText.lowercased()
        return (socialViewModel.users ?? []).filter {
            $0.username.lowercased().contains(lowercasedSearchText)
        }
    }

    private func toggleSelection(for user: User) {
        if let index = selectedFriends.firstIndex(where: { $0.id == user.id }) {
            selectedFriends.remove(at: index)
        } else if selectedFriends.count < maxSelectableFriends {
            selectedFriends.append(user)
        } else {
            // Show alert when trying to select more than the allowed number of friends
            alertMessage = "You can only tag up to \(maxSelectableFriends) friends."
            showAlert = true
        }
    }
}


struct FriendCard: View {
    var user: User
    var selected: Bool

    var body: some View {
        HStack {
            ProfileImage(user: user, size: .medium) // Reduced size
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                Text(user.username)
                    .font(.subheadline) // Smaller font
                    .foregroundColor(.primary)
            }

            Spacer()

            if selected {
                Image(systemName: "checkmark.circle.fill") // More visible checkmark
                    .foregroundColor(.blue)
            }
        }
        .padding(5) // Smaller padding
        .background(selected ? Color.blue.opacity(0.2) : Color.secondary.opacity(0.1)) // Highlight selected
        .cornerRadius(6) // Slightly rounded corners
    }
}

struct MicroFriendCard: View {
    var user: User
    
    var body: some View {
        HStack {
            ProfileImage(user: user, size: .xxsmall)
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

/*
 // Define a mock user and a list of friends for preview
 struct TagPeopleView_Previews: PreviewProvider {
 static var previews: some View {
 // Mock user
 let mockUser = User(id: "1", username: "mockUser", email: "mockuser@example.com")
 
 // Mock friends list
 let mockFriends = [
 User(id: "2", username: "friend1", email: "friend1@example.com"),
 User(id: "3", username: "friend2", email: "friend2@example.com"),
 User(id: "4", username: "friend3", email: "friend3@example.com"),
 User(id: "5", username: "friend4", email: "friend4@example.com"),
 User(id: "6", username: "friend5", email: "friend5@example.com"),
 User(id: "7", username: "friend6", email: "friend6@example.com"),
 User(id: "8", username: "friend7", email: "friend7@example.com"),
 User(id: "9", username: "friend8", email: "friend8@example.com"),
 User(id: "10", username: "friend9", email: "friend9@example.com"),
 User(id: "11", username: "friend10", email: "friend10@example.com"),
 User(id: "12", username: "friend11", email: "friend11@example.com"),
 User(id: "13", username: "friend12", email: "friend12@example.com"),
 User(id: "14", username: "friend13", email: "friend13@example.com"),
 User(id: "15", username: "friend14", email: "friend14@example.com"),
 User(id: "16", username: "friend15", email: "friend15@example.com")
 ]
 
 // Initialize SocialViewModel with the mock user and friends
 let mockSocialViewModel = SocialViewModel(user: mockUser)
 mockSocialViewModel.friends = mockFriends
 
 return TagPeopleViewWrapper()
 .environmentObject(mockSocialViewModel)
 .previewLayout(.sizeThatFits)
 .padding()
 }
 }
 
 struct TagPeopleViewWrapper: View {
 @State var selectedFriends: [User] = []
 
 var body: some View {
 TagPeopleView(selectedFriends: $selectedFriends)
 }
 }
 */
