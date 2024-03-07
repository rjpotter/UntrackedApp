// LoginView.swift

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Provided ZStack as the background
                ZStack {
                    Rectangle()
                        .fill(Color(red: 0.8, green: 0.4, blue: 0.0))
                        .background(Color(red: 0.8, green: 0.4, blue: 0.0))
                    VStack(spacing: 0) { // Set spacing to 0
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)

                        Text("Untracked")
                            .font(Font.custom("Good Times", size:30))
                            .foregroundColor(.white)
                            .padding(.top, -60)

                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    Rectangle()
                        .fill(Color.black.opacity(focusedField != nil ? 0.5 : 0)) // Adjust opacity as needed
                        .edgesIgnoringSafeArea(.all)
                }
                .edgesIgnoringSafeArea(.all)
                
                // Login Form Overlay
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Spacer()
                    
                    // Email Field
                    Text("Email:")
                        .foregroundColor(.white)
                    TextField("Enter your email", text: $viewModel.email)
                        .applyTextFieldStyle()
                        .focused($focusedField, equals: .email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .submitLabel(.next)
                        .padding(.vertical, 5)

                    // Password Field
                    Text("Password:")
                        .foregroundColor(.white)
                    SecureField("Enter your password", text: $viewModel.password)
                        .applyTextFieldStyle()
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
                        .submitLabel(.done)
                        .padding(.vertical, 5)

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.bottom)
                    }
                    
                    // Login Button
                    Button("Login") {
                        focusedField = nil // Dismiss keyboard
                        Task { try await viewModel.signIn() }
                    }
                    .padding()
                    .frame(width: 300, height: 60)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(5)
                    .padding()

                    // Signup Link
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
                    .padding(.bottom, 50)
                    
                    Spacer()
                }
            }
        }
        .accentColor(.white)
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            default:
                focusedField = nil
            }
        }
    }
}

enum FocusField {
    case username, email, password
}
