//
//  EditProfileView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    let user: User
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: EditProfileViewModel
    @State private var showAlert = false
    @State private var isShowingProfileImagePicker = false
    @State private var isShowingBannerImagePicker = false
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            BannerImage(user: user)
                .frame(height: 310) // Adjust height as needed
            ScrollView {
                ZStack {
                    Rectangle()
                        .fill(Color("Base"))
                        .offset(y: 250)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    VStack {
                        VStack(alignment: .leading) {
                            Spacer(minLength: 170) // Reduced minLength for less space above the profile image
                            
                            ProfileImage(user: user, size: ProfileImageSize.large)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                                .offset(x: 15) // Adjusted offset for less vertical space
                            
                            VStack {
                                HStack {
                                    Text(user.username)
                                        .font(.system(size: 25))
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                .padding(.leading)
                                
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        isShowingProfileImagePicker = true
                                    }) {
                                        Label("Edit Profile Image", systemImage: "pencil")
                                            .labelStyle(IconLabelStyle())
                                    }
                                    .sheet(isPresented: $isShowingProfileImagePicker) {
                                        PhotosPicker(selection: $viewModel.selectedImage, matching: .images) {
                                            Text("Select a photo")
                                        }
                                    }
                                    
                                    Button(action: {
                                        isShowingBannerImagePicker = true
                                    }) {
                                        Label("Edit Banner Image", systemImage: "pencil")
                                            .labelStyle(IconLabelStyle())
                                    }
                                    .sheet(isPresented: $isShowingBannerImagePicker) {
                                        PhotosPicker(selection: $viewModel.selectedBannerImage, matching: .images) {
                                            Text("Select a photo")
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                            }
                        }
                        
                        EditProfileRowView(title: "Username", placeholder: "Update username", text: $viewModel.username)
                        // EditProfileRowView(title: "Email", placeholder: "Update email", text: $email)
                        // EditProfileRowView(title: "Password", placeholder: "Update password", text: $password)
                    }
                }
            }
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrowshape.backward")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                }
                .zIndex(1)
                
                Spacer()
                
                Text("Edit Profile")
                    .fontWeight(.semibold)
                    .font(.system(size: 25))
                
                Spacer()
                
                Button("Done") {
                    Task { try await viewModel.updateUserData() }
                    dismiss()
                }
                .padding(10)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding([.leading, .trailing, .bottom])
            .background(Color("Base"))
        }
    }
}

struct EditProfileRowView: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
        }
        .padding()
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(10)
    }
}
