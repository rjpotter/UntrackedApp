import Foundation
import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class UploadPostViewModel: ObservableObject {
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    @Published var postImage: Image?
    private var uiImage: UIImage?
    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.postImage = Image(uiImage: uiImage)
    }
    
    func uploadPost(caption: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let uiImage = self.uiImage else { return }
        
        let postRef = Firestore.firestore().collection("posts").document()
        guard let imageURL = try await ImageUploader.uploadImage(image: uiImage, imageType: ImageType.postImage) else { return }
        let post = Post(id: postRef.documentID, ownerUID: uid, caption: caption, likes: 0, imageURL: imageURL, timestamp: Timestamp())
        
        // Encode and send post
        guard let encodedPost = try? Firestore.Encoder().encode(post) else { return }
        try await postRef.setData(encodedPost)
    }
}
