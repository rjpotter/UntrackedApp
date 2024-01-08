//
//  EditProfileViewModel.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import SwiftUI
import UIKit
import PhotosUI
import FirebaseFirestore

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    @Published var profileImage: Image?
    @Published var username = ""

    @Published var user: User

    private var uiImage: UIImage?

    // Additions for banner image
    @Published var selectedBannerImage: PhotosPickerItem? {
        didSet { Task { await loadBannerImage(fromItem: selectedBannerImage) } }
    }
    @Published var bannerImage: Image?
    private var uiBannerImage: UIImage?

    init(user: User) {
        self.user = user
    }

    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }

    // Function to load banner image
    func loadBannerImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiBannerImage = UIImage(data: data) else { return }
        self.uiBannerImage = uiBannerImage
        self.bannerImage = Image(uiImage: uiBannerImage)
    }

    func updateUserData() async throws {
        var data = [String: Any]()
        
        // Handling profile image upload
        if let uiImage = uiImage {
            let imageURL = try? await ImageUploader.uploadImage(image: uiImage, imageType: .profileImage)
            data["profileImageURL"] = imageURL
        }

        // Handling banner image upload
        if let uiBannerImage = uiBannerImage {
            let bannerImageURL = try? await ImageUploader.uploadImage(image: uiBannerImage, imageType: .bannerImage)
            data["bannerImageURL"] = bannerImageURL
        }

        // Handling username update
        if !username.isEmpty && user.username != username {
            data["username"] = username
        }

        if !data.isEmpty {
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }

        // Reload user data
        let _ = try await AuthService.shared.loadUserData()
    }
}

