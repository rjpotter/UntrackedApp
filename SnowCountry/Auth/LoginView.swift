import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome Shredders")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 50)  // Add padding to the top instead of offset
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.plain)
                    .font(.system(size: 25, weight: .bold))
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.plain)
                    .font(.system(size: 25, weight: .bold))
                
                Button("Login") {
                    Task { try await viewModel.signIn() }
                }
                .frame(width: 100, height: 60)
                .foregroundColor(Color.white)
                .background(Color.black)
                
                Spacer()
                
                NavigationLink {
                    SignupView()
                } label: {
                    HStack {
                        Text("Don't have an account?")
                        
                        Text("Signup")
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 50)  // Add padding to the bottom
            }
        }
    }
}
