import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("background-login")
                    .resizable()
                 
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Text("Welcome Shredders")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.top, 70)
                        .shadow(color: Color.black, radius: 3, x: 2, y: 2)
                        .padding(.bottom, 70)
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .textFieldStyle(.plain)
                        .font(.system(size: 25, weight: .bold))
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .textInputAutocapitalization(.never)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(5)
                        .frame(width: 300, height: 50)
                        .padding()
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .textFieldStyle(.plain)
                        .font(.system(size: 25, weight: .bold))
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(5)
                        .frame(width: 300)
                        .frame(width: 300, height: 50)
                        .padding()
                    Button("Login") {
                        Task { try await viewModel.signIn() }
                    }
                    .padding()
                    .frame(width: 300, height: 60)
                    .foregroundColor(Color.white)
                    .background(Color.orange)
                    .cornerRadius(5)
                    
                
                    
                    NavigationLink {
                        SignupView()
                    } label: {
                        HStack {
                            Text("Don't have an account?")
                            
                            Text("Signup")
                                .fontWeight(.semibold)
                        }
                        .frame(width: 250, height: 40)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                    }
                    .padding(.bottom, 50)  // Add padding to the bottom
                    
                }
            }
        }
    }
}
