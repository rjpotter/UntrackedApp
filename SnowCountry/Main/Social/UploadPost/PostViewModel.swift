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
    
    func postContent(images: [UIImage], caption: String) async {
        isPosting = true
        
        // Get current user ID
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
                imageURLs: imageURLs, // Correct argument label
                runURL: nil, // Add runURL if applicable
                timestamp: Timestamp(),
                user: nil // Optionally populate with user details
            )
            
            try await savePost(newPost)
            
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

