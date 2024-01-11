//
//  EditProfileView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: EditProfileViewModel
    @State private var showAlert = false
    @State private var isShowingProfileImagePicker = false
    @State private var isShowingBannerImagePicker = false

    init(user: User) {
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }

    var body: some View {
        ScrollView { // Use ScrollView to accommodate all content
            VStack {
                HStack {
                    Spacer()
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
                    Spacer()
                    Button("Done") {
                        Task { try await viewModel.updateUserData() }
                        dismiss()
                    }
                    Spacer()
                }
                .padding() // Padding for the top HStack

                Divider()

                VStack {
                    ZStack(alignment: .leading) {
                        BannerImage(user: viewModel.user)
                        ProfileImage(user: viewModel.user, size: ProfileImageSize.large)
                            .offset(x: 70, y: 70)
                    }
                    .frame(height: 250) // Adjust this height to fit the images

                    HStack(spacing: 15) {
                        Button("Edit Profile Picture") {
                            isShowingProfileImagePicker = true
                        }
                        .sheet(isPresented: $isShowingProfileImagePicker) {
                            PhotosPicker(selection: $viewModel.selectedImage, matching: .images) {
                                Text("Select a photo")
                            }
                        }

                        Spacer()

                        Button("Edit Banner Image") {
                            isShowingBannerImagePicker = true
                        }
                        .sheet(isPresented: $isShowingBannerImagePicker) {
                            PhotosPicker(selection: $viewModel.selectedBannerImage, matching: .images) {
                                Text("Select a photo")
                            }
                        }
                    }
                    .padding() // Add vertical padding
                }
                .padding(.bottom) // Add some padding at the bottom of the VStack

                Divider()

                EditProfileRowView(title: "Username", placeholder: "Update username", text: $viewModel.username)

                // Future fields for email and password
                // EditProfileRowView(title: "Email", placeholder: "Update email", text: $email)
                // EditProfileRowView(title: "Password", placeholder: "Update password", text: $password)
            }
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
            Spacer() // Add a Spacer to push TextField to the right
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Style the TextField
                .frame(width: 200) // Adjust the width as needed
        }
        .padding() // Add padding to each row for better spacing
    }
}
