//SignupView.swift

import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = SignupViewModel()

    var body: some View {
        
        ZStack {
            // Background Image
            Image("login")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 0)
                .edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    // Back button
                    Button(action: {
                        LoginView()
                    }) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                            .foregroundColor(.white)
                            .padding()
                    }

                    Spacer()
                }

                Text("SnowCountry")
                    .font(Font.custom("Good Times", size: 30))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                ScrollView {
                    
                    Text("Username:")
                        .foregroundColor(.white)
                    TextField("", text: $viewModel.username)
                        .applyTextFieldStyle()
                        .padding(.vertical, 10)
                    
                    Text("Email:")
                        .foregroundColor(.white)
                    // Display email error prompt
                    if !viewModel.emailError.isEmpty {
                        Text(viewModel.emailError)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.red)
                        
                    }
                    TextField("", text: $viewModel.email)
                        .applyTextFieldStyle()
                        .onChange(of: viewModel.email) { newEmailValue in
                            _ = viewModel.isEmailValid(email: newEmailValue)
                        }
                        .padding(.vertical, 10)
                    
                    Text("Password:")
                        .foregroundColor(.white)
                    // Display password error prompt
                    if !viewModel.passwordError.isEmpty {
                        Text(viewModel.passwordError)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.red)
                        
                    }
                    SecureField("", text: $viewModel.password)
                        .applyTextFieldStyle()
                        .onChange(of: viewModel.password) { newPasswordValue in
                            _ = viewModel.isPasswordValid(password: newPasswordValue)
                            
                        }
                        .padding(.vertical, 10)
                    
                    Button("Sign Up") {
                        Task {
                            try await viewModel.createUser()
                        }
                    }
                    .padding()
                    .frame(width: 300, height: 60)
                    .foregroundColor(Color.white)
                    .background(Color.orange)
                    .cornerRadius(5)
                    .padding()
                }
            }
        }
    }
}

// this just styles the text boxes 
extension View {
    func applyTextFieldStyle() -> some View {
        self
            .padding()
            .font(.system(size: 20, weight: .semibold))
            
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
     
            
            .overlay(
                Rectangle()
                    .stroke(Color.white, lineWidth: 1)
            )
            .frame(width: 300, height: 50)
            .padding()	
            .foregroundColor(.white)
    }
}
