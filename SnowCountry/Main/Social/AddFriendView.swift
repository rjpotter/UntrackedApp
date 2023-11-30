import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    @StateObject var viewModel: AddFriendViewModel
//    @State var password = ""
//    @State var email = ""
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: AddFriendViewModel(user: user))
    }
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center) {
                Text("Add a friend")
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            
            NavigationStack {
                ScrollView {
                    // Lazy VStack bc of the possibility of a lot of users here... Don't want them all to load
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.users) { user in
                            if user != viewModel.user {
                                NavigationLink(value: user) {
                                    HStack {
                                        ProfileImage(user: user, size: ProfileImageSize.xsmall)
                                        
                                        Text(user.username)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search for a friend")
                }
                .navigationTitle("Find Friends Today!")
                .navigationDestination(for: User.self, destination: { user in
                    FriendProfileView(user: user) // Pass in the user here
                })
            }
        }
    }
}


