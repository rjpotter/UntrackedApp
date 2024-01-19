// LoginView.swift

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("login")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 0)
                
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 0) {
                    Text("SnowCountry")
                        .font(Font.custom("Good Times", size:30))
                        .offset(y: -40)
                        .foregroundColor(.white)
                    
                    Text("Email:")
                        .foregroundColor(.white)
                    TextField("", text: $viewModel.email)
                        .applyTextFieldStyle()
                        .padding(.vertical, 5)
                    Text("Password:")
                        .foregroundColor(.white)
                    SecureField("", text: $viewModel.password)
                        .applyTextFieldStyle()
                        
                    Button("Login") {
                        Task { try await viewModel.signIn() }
                    }
                    .padding()
                    .frame(width: 300, height: 60)
                    .foregroundColor(Color.white)
                    .background(Color.orange)
                    .cornerRadius(5)
                    .padding() 
                
                    
                    NavigationLink {
                        SignupView()
                    } label: {
                        HStack {
                            Text("Don't have an account?")
                            
                            Text("Signup")
                                .fontWeight(.semibold)
                        }
                        .frame(width: 250, height: 40)
                      
                        .foregroundColor(Color.white)
                        
                    }
                    .padding(.bottom, 50)  // Add padding to the bottom
                   /*
                    AppleSignInButton()
                        .frame(height: 44)
                        .padding()
                        .onTapGesture {
                            viewModel.signInWithApple()
                        }

                    Button(action: {
                        viewModel.signInWithGoogle()
                    }) {
                        Text("Sign In with Google")
                        // Style the button as needed
                    }
                    .padding()
                    */
                }
            }
        }
        .accentColor(.orange)
    }
}
/*
struct AppleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton()
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}
*/
