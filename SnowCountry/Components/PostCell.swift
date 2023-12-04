import SwiftUI
import Kingfisher

struct PostCell: View {
    let post: Post
    
    var body: some View {
        VStack {
            if let user = post.user {
                HStack {
                    ProfileImage(user: user, size: ProfileImageSize.xsmall)
                    
                    Text(user.username)
                }
            }
            
            if let imageURL = post.imageURL {
                KFImage(URL(string: imageURL))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                    .clipShape(Rectangle())
            }
            
            
            Text(post.caption)
        }
    }
}
