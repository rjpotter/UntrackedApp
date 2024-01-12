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
        ScrollView {
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrowshape.backward")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }

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
                
                ZStack(alignment: .leading) {
                    if let bannerImageURL = viewModel.user.bannerImageURL, URL(string: bannerImageURL) != nil {
                        BannerImage(user: viewModel.user)
                    } else {
                        Color.clear // Empty view to maintain layout
                    }
                    ProfileImage(user: user, size: ProfileImageSize.large)
                        .offset(x: 15, y: 70)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack{
                            Text(user.username)
                                .font(.system(size: 25))
                                .fontWeight(.semibold)
                                .offset(x: 5, y: 210)
                                .padding(.leading)
                        }
                        
                        HStack(spacing: 10) {
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
                        }
                        .offset(x: 10, y: 215)
                        .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                    }
                }
                .padding(.top, -12)
                .padding(.bottom, 170)

                Divider()

                EditProfileRowView(title: "Username", placeholder: "Update username", text: $viewModel.username)

                // Future fields for email and password
                // EditProfileRowView(title: "Email", placeholder: "Update email", text: $email)
                // EditProfileRowView(title: "Password", placeholder: "Update password", text: $password)
            }
        }
        .background(Color.systemBackground)
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
