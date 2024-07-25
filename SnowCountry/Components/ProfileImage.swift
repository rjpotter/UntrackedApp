import SwiftUI
import Kingfisher

enum ProfileImageSize {
    case xxsmall
    case xsmall
    case small
    case medium
    case large
    
    var dimension: CGFloat {
        switch self {
        case .xxsmall:
            return 30
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
        GeometryReader { geometry in
            if let bannerImageURL = user.bannerImageURL, let url = URL(string: bannerImageURL) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 200) // Set width to screen width
                    .clipped()
            } else {
                Image("defaultBannerImage") // Replace with your default banner image name
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 200) // Set width to screen width
                    .clipped()
            }
        }
        .frame(height: 200) // Set a fixed height
    }
}
