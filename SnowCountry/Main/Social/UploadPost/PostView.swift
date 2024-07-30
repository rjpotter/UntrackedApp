//
//  PostView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/24/24.
//

import SwiftUI

struct PostView: View {
    @ObservedObject var socialViewModel: SocialViewModel
    @StateObject private var uploadPostViewModel = UploadPostViewModel()
    @State var images: [UIImage]
    @State private var caption: String = "Write a caption..."
    @State private var selectedIndex: Int = 0
    @State private var isFullScreen: Bool = false
    @State private var showStokeLevelPicker: Bool = false
    @State private var showTagPeople: Bool = false
    @State private var showLocationPicker: Bool = false
    @State private var stokeLevel: Int = 0
    @State private var taggedFriends: [User] = []
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigateBackToRoot: Bool
    @State private var isLoading = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Uploading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Display the collage of images
                        CollageView(images: images)
                            .onTapGesture {
                                isFullScreen = true
                            }
                        
                        // Caption input
                        TextEditor(text: $caption)
                            .focused($isFocused)
                            .frame(height: 100)
                            .scrollContentBackground(.hidden)
                            .background(Color("Base"))
                            .padding(.horizontal)
                            .foregroundColor(caption == "Write a caption..." ? .gray : .primary) // Text color
                            .onTapGesture {
                                if caption == "Write a caption..." {
                                    caption = ""
                                }
                                isFocused = true
                            }
                            .onChange(of: isFocused) { focused in
                                if !focused && caption.isEmpty {
                                    caption = "Write a caption..."
                                }
                            }
                        
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
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                if !isFocused {
                    // Share button fixed at the bottom
                    Button(action: {
                        Task {
                            isLoading = true // Start loading
                            await uploadPost()
                            isLoading = false // Stop loading
                            navigateBackToRoot = true // Set the binding to navigate back to root
                        }
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
        .navigationTitle(isFocused ? "Editing Caption" : "New Post")
        .toolbar {
            if isFocused {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isFocused = false
                    }) {
                        Text("Done")
                    }
                }
            }
        }
        .onAppear {
            isFocused = false // Ensure isEditing is false on view appear
        }
        .background(Color("Base").ignoresSafeArea())
    }
    
    func uploadPost() async {
        await uploadPostViewModel.postContent(images: images, caption: caption, stokeLevel: stokeLevel, taggedUsers: taggedFriends)
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
     @State static var exampleImages: [UIImage] = (1...1).compactMap { UIImage(named: "photo\($0)") }
     
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
         User(id: "13", username: "friend12", email: "friend2@example.com"),
         User(id: "14", username: "friend13", email: "friend13@example.com"),
         User(id: "15", username: "friend14", email: "friend14@example.com"),
         User(id: "16", username: "friend15", email: "friend15@example.com")
     ]
         
     // Initialize SocialViewModel with the mock user and friends
     let mockSocialViewModel = SocialViewModel(user: mockUser)
     mockSocialViewModel.friends = mockFriends
     
     return PostView(
         socialViewModel: mockSocialViewModel,
         images: exampleImages,
         navigateBackToRoot: .constant(false)
     )
     .environmentObject(mockSocialViewModel)
     .previewLayout(.sizeThatFits)
     .padding()
     }
 }
