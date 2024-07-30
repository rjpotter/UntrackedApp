//
//  PostViewModel.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/24/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UploadPostViewModel: ObservableObject {
    @Published var isPosting = false

    func postContent(images: [UIImage], caption: String, stokeLevel: Int, taggedUsers: [User]) async {
        DispatchQueue.main.async {
            self.isPosting = true
        }

        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: No current user logged in.")
            DispatchQueue.main.async {
                self.isPosting = false
            }
            return
        }

        do {
            var imageURLs: [String] = []

            for image in images {
                if let url = try await uploadImage(image: image) {
                    imageURLs.append(url)
                }
            }

            let newPost = Post(
                id: UUID().uuidString,
                ownerUID: currentUserUID,
                caption: caption == "Write a caption..." ? "" : caption,
                likedBy: nil,
                likes: 0,
                imageURLs: imageURLs,
                stokeLevel: stokeLevel,
                taggedUsers: taggedUsers,
                timestamp: Timestamp(),
                user: nil // You can populate this with current user details if needed
            )

            // Save post to Firestore
            try await savePost(newPost)

        } catch {
            print("Failed to post content: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.isPosting = false
        }
    }

    private func uploadImage(image: UIImage) async throws -> String? {
        return try await ImageUploader.uploadImage(image: image, imageType: .postImage)
    }

    private func savePost(_ post: Post) async throws {
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(post.id)
        
        // Convert post to dictionary for saving
        let postData: [String: Any] = [
            "id": post.id,
            "ownerUID": post.ownerUID,
            "caption": post.caption,
            "likedBy": post.likedBy,
            "likes": post.likes,
            "imageURLs": post.imageURLs ?? [],
            "stokeLevel": post.stokeLevel ?? 0,
            "timestamp": post.timestamp,
            "user": post.user?.dictionary ?? [:],
            "taggedUsers": post.taggedUsers?.map { $0.dictionary } ?? []
        ]

        try await postRef.setData(postData)
    }
}

private extension Post {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "ownerUID": ownerUID,
            "caption": caption,
            "likedBy": likedBy,
            "likes": likes,
            "imageURLs": imageURLs ?? [],
            "stokeLevel": stokeLevel ?? 0,
            "timestamp": timestamp,
            "user": user?.dictionary ?? [:],
            "taggedUsers": taggedUsers?.map { $0.dictionary } ?? []
        ]
    }
}

private extension User {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "username": username,
            "email": email,
            "profileImageURL": profileImageURL ?? "" // Add this if needed
        ]
    }
}
