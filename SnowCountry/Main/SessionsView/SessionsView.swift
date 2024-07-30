//
//  SessionsView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.
//

import SwiftUI
import Kingfisher

// A simple model for the Ski Session (group chat or single chat)
struct SkiSession: Identifiable {
    var id = UUID()
    var name: String
    var lastMessage: String
    var groupPhoto: String? // Name of the image asset, or use a default icon
    var unreadCount: Int
    var isPinned: Bool
    var isGroupChat: Bool
    var user: User? // For direct messages, associate a User
}

struct SessionsView: View {
    @State private var selectedFilter: ChatFilter = .all // State to manage the filter
    @State private var searchText: String = ""
    @State private var skiSessions: [SkiSession]
    
    enum ChatFilter {
        case all, single, group
    }
    
    // Initialize with default data
    init(skiSessions: [SkiSession] = SessionsView.defaultSessions()) {
        _skiSessions = State(initialValue: skiSessions)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Base").ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("Chats")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            // Action for editing chats
                        }) {
                            Text("Edit")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    HStack {
                        SearchBarView(text: $searchText)
                    }
                    .padding(.horizontal)

                    // Toggle Buttons for filtering
                    HStack(spacing: 20) {
                        Button(action: {
                            selectedFilter = .all
                        }) {
                            Text("All")
                                .foregroundColor(selectedFilter == .all ? .blue : .gray)
                        }
                        
                        Button(action: {
                            selectedFilter = .single
                        }) {
                            Text("Single")
                                .foregroundColor(selectedFilter == .single ? .blue : .gray)
                        }
                        
                        Button(action: {
                            selectedFilter = .group
                        }) {
                            Text("Groups")
                                .foregroundColor(selectedFilter == .group ? .blue : .gray)
                        }
                        Spacer()
                        Button(action: {
                            // Action for creating new chat
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    
                    List {
                        // Pinned chats section
                        if skiSessions.contains(where: { $0.isPinned }) {
                            Section(header: Text("Pinned")) {
                                ForEach(filteredSessions.filter { $0.isPinned }) { session in
                                    ChatRow(session: session, togglePinned: togglePinned)
                                        .swipeActions(edge: .leading) {
                                            Button(action: {
                                                togglePinned(session)
                                            }) {
                                                Label(session.isPinned ? "Unpin" : "Pin", systemImage: session.isPinned ? "pin.slash.fill" : "pin.fill")
                                            }
                                            .tint(session.isPinned ? .gray : .blue)
                                        }
                                }
                            }
                        }
                        
                        // All other chats
                        ForEach(filteredSessions.filter { !$0.isPinned }) { session in
                            ChatRow(session: session, togglePinned: togglePinned)
                                .swipeActions(edge: .leading) {
                                    Button(action: {
                                        togglePinned(session)
                                    }) {
                                        Label(session.isPinned ? "Unpin" : "Pin", systemImage: session.isPinned ? "pin.slash.fill" : "pin.fill")
                                    }
                                    .tint(session.isPinned ? .gray : .blue)
                                }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Filtered sessions based on the selected filter and search text
    var filteredSessions: [SkiSession] {
        let searchLowercased = searchText.lowercased()
        return skiSessions.filter { session in
            let matchesFilter = (selectedFilter == .all)
                || (selectedFilter == .single && !session.isGroupChat)
                || (selectedFilter == .group && session.isGroupChat)
            let matchesSearch = searchLowercased.isEmpty
                || session.name.lowercased().contains(searchLowercased)
                || (session.user?.username.lowercased().contains(searchLowercased) ?? false)
            
            return matchesFilter && matchesSearch
        }
    }
    
    static func defaultSessions() -> [SkiSession] {
        let sampleUsers = [
            User(id: "1", username: "JohnDoe", email: "john@example.com", profileImageURL: "photo3"),
            User(id: "2", username: "JaneSmith", email: "jane@example.com", profileImageURL: ""),
            User(id: "3", username: "MikeJohnson", email: "mike@example.com", profileImageURL: "photo5"),
            User(id: "4", username: "EmilyClark", email: "emily@example.com", profileImageURL: "photo2"),
            User(id: "5", username: "DavidBrown", email: "david@example.com", profileImageURL: "photo4"),
            User(id: "6", username: "SophiaDavis", email: "sophia@example.com", profileImageURL: "photo6")
        ]
        
        return [
            SkiSession(name: "Beginners Group", lastMessage: "See you on the slopes!", groupPhoto: "", unreadCount: 2, isPinned: false, isGroupChat: true, user: nil),
            SkiSession(name: "Expert Run", lastMessage: "Ready for the next challenge?", groupPhoto: "photo10", unreadCount: 0, isPinned: true, isGroupChat: true, user: nil),
            SkiSession(name: "John Doe", lastMessage: "Don't forget your gear!", groupPhoto: "", unreadCount: 1, isPinned: false, isGroupChat: false, user: sampleUsers[0]),
            SkiSession(name: "Jane Smith", lastMessage: "See you tomorrow!", groupPhoto: "", unreadCount: 3, isPinned: true, isGroupChat: false, user: sampleUsers[1]),
            SkiSession(name: "Mountain Explorers", lastMessage: "Who's in for the weekend?", groupPhoto: "photo8", unreadCount: 0, isPinned: false, isGroupChat: true, user: nil),
            SkiSession(name: "Mike Johnson", lastMessage: "Check out this new trail!", groupPhoto: "", unreadCount: 2, isPinned: false, isGroupChat: false, user: sampleUsers[2]),
            SkiSession(name: "Emily Clark", lastMessage: "Had a great time skiing!", groupPhoto: "", unreadCount: 0, isPinned: false, isGroupChat: false, user: sampleUsers[3]),
            SkiSession(name: "David Brown", lastMessage: "Let’s plan the next trip.", groupPhoto: "", unreadCount: 4, isPinned: false, isGroupChat: false, user: sampleUsers[4]),
            SkiSession(name: "Sophia Davis", lastMessage: "Snow conditions are perfect!", groupPhoto: "", unreadCount: 5, isPinned: false, isGroupChat: false, user: sampleUsers[5]),
            SkiSession(name: "Alpine Adventurers", lastMessage: "Meeting at 9 AM.", groupPhoto: "photo7", unreadCount: 0, isPinned: true, isGroupChat: true, user: nil)
        ]
    }
    
    private func togglePinned(_ session: SkiSession) {
        if let index = skiSessions.firstIndex(where: { $0.id == session.id }) {
            skiSessions[index].isPinned.toggle()
        }
    }
}

struct ChatRow: View {
    var session: SkiSession
    var togglePinned: (SkiSession) -> Void

    var body: some View {
        HStack {
            Group {
                if !session.isGroupChat, let user = session.user {
                    // Direct message: use the user's profile image or a placeholder
                    if let profileImageURL = user.profileImageURL, !profileImageURL.isEmpty {
                        Image(profileImageURL) // Assuming profileImageURL is the name of an asset
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                } else {
                    // Group chat: use the group photo or a placeholder
                    if let groupPhoto = session.groupPhoto, !groupPhoto.isEmpty {
                        Image(groupPhoto) // Assuming groupPhoto is the name of an asset
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))

            VStack(alignment: .leading) {
                HStack {
                    Text(session.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if session.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                Text(session.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
            
            if session.unreadCount > 0 {
                Text("\(session.unreadCount)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
}

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.vertical, 10)
    }
}

// Preview with predefined data
struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView(skiSessions: SessionsView.defaultSessions())
    }
}
