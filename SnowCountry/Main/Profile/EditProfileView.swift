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
        VStack {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Edit Profile")
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    Task { try await viewModel.updateUserData() }
                    dismiss()
                }
            }

            Divider()

            VStack {
                ZStack(alignment: .leading) {
                    BannerImage(user: viewModel.user)
                    ProfileImage(user: viewModel.user, size: ProfileImageSize.large)
                        .offset(x: 70, y: 70)
                }
                .frame(height: 250) // Adjust this height to fit the images

                // A smaller space or padding for better control
                HStack(spacing: 15) { // Adjust spacing as needed
                    Spacer()
                    Button("Edit Profile Picture") {
                        isShowingProfileImagePicker = true
                    }
                    .sheet(isPresented: $isShowingProfileImagePicker) {
                        PhotosPicker(selection: $viewModel.selectedImage, matching: .images) {
                            Text("Select a photo")
                        }
                    }
                    
                    Button("Edit Banner Image") {
                        isShowingBannerImagePicker = true
                    }
                    .sheet(isPresented: $isShowingBannerImagePicker) {
                        PhotosPicker(selection: $viewModel.selectedBannerImage, matching: .images) {
                            Text("Select a photo")
                        }
                    }
                    Spacer()
                }
                .padding(.vertical) // Add vertical padding
            }


            Divider()

            EditProfileRowView(title: "Username", placeholder: "Update username", text: $viewModel.username)

            // Future fields for email and password
            // EditProfileRowView(title: "Email", placeholder: "Update email", text: $email)
            // EditProfileRowView(title: "Password", placeholder: "Update password", text: $password)
            
            Spacer()

            Button(action: {
                showAlert = true
            }) {
                Text("Logout")
                    .accentColor(.red)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text ("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Log Out"), action: {
                        AuthService.shared.signOut()
                    })
                )
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
            
            VStack {
                TextField(placeholder, text: $text)
                
                Divider()
            }
        }
    }
}
