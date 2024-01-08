import Foundation
import UIKit
import FirebaseStorage

enum ImageType {
    case profileImage
    case postImage
    case bannerImage
    
    var imageTypeString: String {
        switch self {
        case .profileImage:
            return "/profile_images/"
        case .postImage:
            return "/post_images/"
        case .bannerImage:  // Handle the directory for banner images
            return "/banner_images/"
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage, imageType: ImageType) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil }
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "\(imageType.imageTypeString)\(filename)")
        
        do {
            let _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("error uploading profile image: \(error.localizedDescription)")
            return nil
        }
    }
}
