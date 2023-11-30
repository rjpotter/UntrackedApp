import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: EditProfileViewModel
//    @State var password = ""
//    @State var email = ""
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Edit Profile")
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    Task { try await viewModel.updateUserDate() }
                    dismiss()
                }
            }
            
            Divider()
            
            PhotosPicker(selection: $viewModel.selectedImage) {
                VStack {
                    if let image = viewModel.profileImage {
                        image
                            .resizable()
                            .frame(width: 60, height: 60)
                    } else {
                        ProfileImageView(user: viewModel.user)
                    }
                    
                    Text("Edit Profile Picture")
                }
            }
            
            Divider()
            
          
            
        
            
           
            EditProfileRowView(title: "Username", placeholder: "Update username", text: $viewModel.username)
            
            // Just worrying about username for now bc email and passsword require updating the authentication table
//            EditProfileRowView(title: "Email", placeholder: "Update email", text: $email)
//            EditProfileRowView(title: "Password", placeholder: "Update password", text: $password)
            
            
            Spacer()
            
            // add an are you sure prompt
            Button(action: {
                                    AuthService.shared.signOut()
                                }, label: {
                                    Text("Logout")
                                        .foregroundColor(Color.red)
                                })
        }
    }
}

struct EditProfileRowView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
            
            VStack {
                TextField(placeholder, text: $text)
                
                Divider()
            }
        }
    }
}

