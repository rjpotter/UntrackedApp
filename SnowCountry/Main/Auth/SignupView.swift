//SignupView.swift

import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = SignupViewModel()
    @FocusState private var focusedField: FocusField?
    @Environment(\.dismiss) var dismiss
    
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
                
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                            
                            // Username Field
                            Group {
                                Text("Username:")
                                    .foregroundColor(.white)
                                TextField("Enter your username", text: $viewModel.username)
                                    .applyTextFieldStyle()
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .username)
                            }
                            
                            // Email Field
                            Group {
                                Text("Email:")
                                    .foregroundColor(.white)
                                TextField("Enter your email", text: $viewModel.email)
                                    .applyTextFieldStyle()
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .email)
                            }
                            
                            // Password Field
                            Group {
                                Text("Password:")
                                    .foregroundColor(.white)
                                SecureField("Enter your password", text: $viewModel.password)
                                    .applyTextFieldStyle()
                                    .submitLabel(.done)
                                    .focused($focusedField, equals: .password)
                            }
                            
                            // Login Button
                            Button("Sign Up") {
                                focusedField = nil // Dismiss keyboard
                                Task { try await viewModel.createUser() }
                            }
                            .padding()
                            .frame(width: 300, height: 60)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(5)
                            .padding()
                            
                            // Signup Link
                            Button(action: {
                                dismiss()
                            }) {
                                HStack {
                                    Text("Have an account?")
                                    Text("Log In")
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 250, height: 40)
                                .foregroundColor(Color.white)
                            }
                            .padding(.bottom, 50)
                            
                            Spacer()
                        }
                        .padding(.top, 50)
                    }
                    .edgesIgnoringSafeArea(.all)
                }
                .padding(.top, 100)
            }
            .accentColor(.orange)
            .onSubmit {
                switch focusedField {
                case .username:
                    focusedField = .email
                case .email:
                    focusedField = .password
                default:
                    focusedField = nil
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
