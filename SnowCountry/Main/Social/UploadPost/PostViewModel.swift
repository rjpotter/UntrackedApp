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
        isPosting = true

        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: No current user logged in.")
            isPosting = false
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
                caption: caption,
                likes: 0,
                imageURLs: imageURLs,
                runURL: nil,
                timestamp: Timestamp(),
                user: nil // You can populate this with current user details if needed
            )

            // Save post to Firestore
            try await savePost(newPost)

            // Save additional information like stoke level and tagged users if needed
            // For example, you can update the post document with additional fields:
            let postRef = Firestore.firestore().collection("posts").document(newPost.id)
            try await postRef.setData([
                "stokeLevel": stokeLevel,
                "taggedUsers": taggedUsers.map { $0.dictionary }
            ], merge: true)
            
        } catch {
            print("Failed to post content: \(error.localizedDescription)")
        }

        isPosting = false
    }

    private func uploadImage(image: UIImage) async throws -> String? {
        return try await ImageUploader.uploadImage(image: image, imageType: .postImage)
    }

    private func savePost(_ post: Post) async throws {
        let db = Firestore.firestore()
        try await db.collection("posts").document(post.id).setData(post.dictionary)
    }
}

private extension Post {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "ownerUID": ownerUID,
            "caption": caption,
            "likes": likes,
            "imageURLs": imageURLs ?? [],
            "runURL": runURL ?? "",
            "timestamp": timestamp,
            "user": user?.dictionary ?? [:]
        ]
    }
}

private extension User {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "username": username,
            "email": email,
            // Add other user properties if needed
        ]
    }
}
