import SwiftUI
import Kingfisher

struct ProfileImageView: View {
    let user: User
    
    var body: some View {
        if let imageURL = user.profileImageURL {
            KFImage(URL(string: imageURL))
                .resizable()
                .frame(width: 60, height: 60)
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 80, height: 80)
        }
    }
}
