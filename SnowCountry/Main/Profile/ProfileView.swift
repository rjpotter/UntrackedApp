import SwiftUI

struct ProfileView: View {
    let user: User
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Profile Details")) {
                    HStack {
                        ProfileImageView(user: user)
                        Text(user.username)
                    }
                    Button("Edit Profile") {
                        showEditProfile.toggle()
                    }
                }
                
                
                Section(header: Text("Run History")) {
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    // ... other run histories
                }
                Section(header: Text("Settings")) {
                    Toggle("Dark Mode", isOn: .constant(true)) // Placeholder toggle
                    Button(action: {
                        AuthService.shared.signOut()
                    }, label: {
                        Text("Logout")
                    })
                }
            }
            .navigationTitle("Profile")
        }
        .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileView(user: user)
        }
    }
}
