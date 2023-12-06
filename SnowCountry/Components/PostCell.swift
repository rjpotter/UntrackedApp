import SwiftUI
import Kingfisher

struct PostCell: View {
    let post: Post
 

    var body: some View{
        VStack{
            VStack(alignment: .leading, spacing: 0) {
                if let user = post.user {
                    HStack {
                        ProfileImage(user: user, size: ProfileImageSize.xsmall)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 4)
                            .padding(8)
                        
                        
                        Text(user.username)
                            .font(.headline)
                            .fontWeight(.bold)
                            
                    }
                    .padding(.vertical, 4)
                    
                }
                
                if let imageURL = post.imageURL  {
                    KFImage(URL(string: imageURL))
                        .resizable()
                        .scaledToFit()
                        .clipShape(Rectangle())
                        .padding(.bottom, 8)
                }
                if let user = post.user {
                    HStack{
                        // Add the caption below the image
                        Text(user.username)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 2)
                            .padding(.bottom, 2)
                            .padding(.leading, 5)
                            
                        Text(post.caption)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .padding(.bottom, 2)
                            .lineLimit(nil)
                    }
                }
            }
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
            )
            .padding(.horizontal, -2)
            .background(Color("Base"))
            .shadow(radius: 5)
        }
        
    }
   
}
