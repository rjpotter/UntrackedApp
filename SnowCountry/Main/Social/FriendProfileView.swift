import SwiftUI

struct FriendProfileView: View {
    let user: User
    
    var body: some View {
        Text(user.username)
    }
}

//struct FriendProfileView: View {
//    let user: User
//
//    var body: some view {
//        Text(user.username)
//    }
//}
