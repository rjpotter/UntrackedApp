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
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(10)

                    Spacer()

                    Text("Edit Profile")
                        .fontWeight(.semibold)
                        .font(.system(size: 25))

                    Spacer()

                    Button("Done") {
                        Task { try await viewModel.updateUserData() }
                        dismiss()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()

                Divider()

                VStack {
                    ZStack(alignment: .leading) {
                        BannerImage(user: viewModel.user)
                        ProfileImage(user: viewModel.user, size: ProfileImageSize.large)
                            .offset(x: 70, y: 70)
                    }
                    .frame(height: 250)

                    HStack(spacing: 15) {
                        Button("Edit Profile Picture") {
                            isShowingProfileImagePicker = true
                        }
                        .sheet(isPresented: $isShowingProfileImagePicker) {
                            PhotosPicker(selection: $viewModel.selectedImage, matching: .images) {
                                Text("Select a photo")
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.3))
                        .cornerRadius(10)

                        Spacer()

                        Button("Edit Banner Image") {
                            isShowingBannerImagePicker = true
                        }
                        .sheet(isPresented: $isShowingBannerImagePicker) {
                            PhotosPicker(selection: $viewModel.selectedBannerImage, matching: .images) {
                                Text("Select a photo")
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.3))
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .padding(.bottom)

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
