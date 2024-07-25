//
//  PostView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/24/24.  
//

import SwiftUI

struct PostView: View {
    @ObservedObject var socialViewModel: SocialViewModel
    @State var images: [UIImage]
    @State private var caption: String = ""
    @State private var selectedIndex: Int = 0
    @State private var isFullScreen: Bool = false
    @State private var isEditing: Bool = false
    @State private var showStokeLevelPicker: Bool = false
    @State private var showTagPeople: Bool = false
    @State private var showLocationPicker: Bool = false
    @State private var stokeLevel: Int = 0
    @State private var taggedFriends: [User] = []

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Display the collage of images
                    CollageView(images: images)
                        .onTapGesture {
                            isFullScreen = true
                        }
                    
                    // Caption input
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $caption)
                            .padding(4)
                            .frame(height: 100)
                            .onTapGesture {
                                isEditing = true
                            }
                        
                        if caption.isEmpty {
                            Text("Write a caption...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Additional options similar to Instagram
                    VStack {
                        OptionRow(icon: "star", title: "Rate Stoke Level", stokeLevel: $stokeLevel) {
                            showStokeLevelPicker.toggle()
                        }
                        
                        OptionRow(icon: "person.crop.circle", title: "Tag people", stokeLevel: .constant(0), count: taggedFriends.count) {
                            showTagPeople.toggle()
                        }
                        .sheet(isPresented: $showTagPeople) {
                            TagPeopleView(selectedFriends: $taggedFriends).environmentObject(socialViewModel)
                        }
                        /*
                        OptionRow(icon: "map.circle", title: "Add Location", stokeLevel: .constant(0)) {
                            showLocationPicker.toggle()
                        }
                        .sheet(isPresented: $showLocationPicker) {
                            LocationPickerView()
                        }
                        */
                        // Display selected friends
                        if !taggedFriends.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(taggedFriends, id: \.id) { friend in
                                        MicroFriendCard(user: friend)
                                            .padding(.horizontal, 5)
                                            .padding(.bottom, 10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if !isEditing {
                // Share button fixed at the bottom
                Button(action: {
                    // Handle post action
                }) {
                    Text("Share")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .overlay(
            ZStack {
                if showStokeLevelPicker {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showStokeLevelPicker = false
                        }
                    StokeLevelPickerView(selectedLevel: $stokeLevel)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding()
                }
            }
        )
        .sheet(isPresented: $isFullScreen, content: {
            FullScreenImageView(images: images, selectedIndex: $selectedIndex, isPresented: $isFullScreen)
        })
        .navigationTitle(isEditing ? "Caption" : "New Post")
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        endEditing(true)
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
    
    func endEditing(_ force: Bool) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isEditing = false
    }
}

struct OptionRow: View {
    var icon: String
    var title: String
    @Binding var stokeLevel: Int
    var count: Int = 0 // Additional parameter for the count (e.g., number of selected friends)
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if count > 0 {
                    Text("(\(count))") // Display count if greater than zero
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                }
                if stokeLevel > 0 {
                    HStack {
                        Text("\(stokeLevel)")
                        Image(systemName: "snowflake")
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 10)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
            .padding(.vertical, 10)
            .padding(.leading)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// Define a mock user and a list of friends for preview
struct PostView_Previews: PreviewProvider {
    @State static var exampleImages: [UIImage] = (1...10).compactMap { UIImage(named: "photo\($0)") }
    
    static var previews: some View {
        // Mock user
        let mockUser = User(id: "1", username: "mockUser", email: "mockuser@example.com")
        
        // Mock friends list
        let mockFriends = [
            User(id: "2", username: "friend1", email: "friend1@example.com"),
            User(id: "3", username: "friend2", email: "friend2@example.com"),
            User(id: "4", username: "friend3", email: "friend3@example.com"),
            User(id: "5", username: "friend4", email: "friend4@example.com"),
            User(id: "6", username: "friend5", email: "friend5@example.com")
        ]
        
        // Initialize SocialViewModel with the mock user and friends
        let mockSocialViewModel = SocialViewModel(user: mockUser)
        mockSocialViewModel.friends = mockFriends

        return PostView(
            socialViewModel: mockSocialViewModel,
            images: exampleImages
        )
        .environmentObject(mockSocialViewModel)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
