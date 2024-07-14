// LoginView.swift

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @FocusState private var focusedField: FocusField?
    @State private var rotationAngle: Double = -12
    @State private var offsetY: Double = 0
    @State private var offsetYSignUp: Double = 0
    @State private var offsetYLogIn: Double = 0
    @State private var offsetX: Double = 250
    @State private var boxOpacity: Double = 0.0
    @Binding var showLogin: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width:750, height: 100)
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.0))
                .cornerRadius(30)
                .rotationEffect(.degrees(12))
                .offset(x: -100, y: -300)
                .opacity(1.0)
            Rectangle()
                .frame(width: 750, height: 75)
                .foregroundColor(Color(red: 76/255, green: 95/255, blue: 104/255))
                .cornerRadius(30)
                .rotationEffect(.degrees(12))
                .offset(x: -100, y: -200)
            
            // Email Box Background
            Rectangle()
                .frame(width: 750, height: 50)
                .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                .cornerRadius(30)
                .rotationEffect(.degrees(-rotationAngle))
                .offset(x: -100, y: -125 + offsetY)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        rotationAngle = 0
                        offsetY = 90
                    }
                }
            
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(12))
                .offset(x: 0, y: -275)
            
            Text("Untracked")
                .font(Font.custom("Good Times", size:30))
                .foregroundColor(.white)
                .padding(.top, -60)
                .rotationEffect(.degrees(12))
                .offset(x: -5, y: -137)
            
            Rectangle()
                .frame(width:750, height: 100)
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.0))
                .cornerRadius(30)
                .rotationEffect(.degrees(-12))
                .offset(x: -100, y: 300)
            Rectangle()
                .frame(width: 750, height: 75)
                .foregroundColor(Color(red: 76/255, green: 95/255, blue: 104/255))
                .cornerRadius(30)
                .rotationEffect(.degrees(-12))
                .offset(x: -100, y: 200)

            // Password Box Background
            Rectangle()
                .frame(width: 750, height: 50)
                .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                .cornerRadius(30)
                .rotationEffect(.degrees(rotationAngle))
                .offset(x: -100, y: 125 - offsetY)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        rotationAngle = 0
                        offsetY = 90
                    }
                }
            
            // Email Field
            TextField("Email", text: $viewModel.email)
                .applyTextFieldStyle()
                .focused($focusedField, equals: .email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .padding(.vertical, 5)
                .offset(x: 0, y: -35)
                .opacity(boxOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(1)) {
                        boxOpacity = 1.0
                    }
                }
            
            SecureField("Password", text: $viewModel.password)
                .applyTextFieldStyle()
                .focused($focusedField, equals: .password)
                .textContentType(.password)
                .submitLabel(.done)
                .padding(.vertical, 5)
                .offset(x: 0, y: 35)
                .opacity(boxOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(1)) {
                        boxOpacity = 1.0
                    }
                }
            
            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            
            Button("Log In") {
                focusedField = nil // Dismiss keyboard
                Task { try await viewModel.signIn() }
            }
            .font(Font.custom("Good Times", size: 25))
            .foregroundColor(.white)
            .padding(5)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .background(Color.blue)
            .cornerRadius(10)
            .rotationEffect(.degrees(-12))
            .offset(x: 10 + offsetX, y: 130 + offsetYLogIn)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.45)) {
                    offsetX = -10
                    offsetYLogIn = 50
                }
            }
            
            HStack {
                Text("Don't have an account?")
                    .font(.system(size: 20))
                Button(action: {
                    showLogin = false
                }) {
                    Text("Sign Up")
                        .font(Font.custom("Good Times", size: 20))
                        .foregroundColor(.blue)
                }
            }
            .rotationEffect(.degrees(-12))
            .offset(x: 0, y: 500 - offsetYSignUp)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.45)) {
                    offsetYSignUp = 220
                }
            }
        }
    }
}

enum FocusField {
    case username, email, password
}
