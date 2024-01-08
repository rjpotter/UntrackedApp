import SwiftUI
import Kingfisher

enum ProfileImageSize {
    case xsmall
    case small
    case medium
    case large
    
    var dimension: CGFloat {
        switch self {
        case .xsmall:
            return 40
        case .small:
            return 50
        case .medium:
            return 60
        case .large:
            return 150
        }
    }
}

struct ProfileImage: View {
    let user: User
    let size: ProfileImageSize
    
    var body: some View {
        if let imageURL = user.profileImageURL {
            KFImage(URL(string: imageURL))
                 .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 7)
        } else {
            Image(systemName: "person.fill")
                 .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 7)
        }
    }
}

struct BannerImage: View {
    let user: User
    
    var body: some View {
        if let bannerImageURL = user.bannerImageURL, let url = URL(string: bannerImageURL) {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200) // You can adjust the height as needed
                .clipped()
        } else {
            Image("defaultBannerImage") // Replace with your default banner image name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200) // Adjust height as needed
                .clipped()
        }
    }
}
