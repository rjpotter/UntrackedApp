import SwiftUI
import Kingfisher

struct ProfileImageView: View {
    let user: User
    
    var body: some View {
        if let imageURL = user.profileImageURL {
            KFImage(URL(string: imageURL))
                 .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 7)
        } else {
            Image(systemName: "person.fill")
                 .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 175, height: 175)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 7)
        }
    }
}
