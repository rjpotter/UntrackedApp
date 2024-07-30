//SignupView.swift

import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = SignupViewModel()
    @FocusState private var focusedField: FocusField?
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var offsetY: Double = 0
    @State private var offsetYSignUp: Double = 0
    @State private var offsetYSignUpButton: Double = 0
    @State private var offsetXSignUpButton: Double = 0
    @State private var offsetYLogIn: Double = 0
    @State private var offsetYLogInButton: Double = 0
    @State private var offsetX: Double = 250
    @State private var offsetXUserNameBox: Double = 1000
    @Binding var showLogin: Int
    
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
            
            // Username Box Background
            Rectangle()
                .frame(width: 750, height: 50)
                .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                .cornerRadius(30)
                .offset(x: -100 + offsetXUserNameBox, y: -70)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        offsetXUserNameBox = 0
                    }
                }
            
            // Email Box Background
            Rectangle()
                .frame(width: 750, height: 50)
                .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                .cornerRadius(30)
                .offset(x: -100, y: -35 + offsetY)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        offsetY = 35
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
                .offset(x: -100, y: 35 + offsetY)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                    }
                }
            
            // Username Field
            TextField("Username", text: $viewModel.username)
                .applyTextFieldStyle()
                .submitLabel(.next)
                .focused($focusedField, equals: .username)
                .padding(.vertical, 5)
                .offset(x: 0 + offsetXUserNameBox, y: -70)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(1)) {
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
                .offset(x: 0, y: -35 + offsetY)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(1)) {
                    }
                }
            
            SecureField("Password", text: $viewModel.password)
                .applyTextFieldStyle()
                .focused($focusedField, equals: .password)
                .textContentType(.password)
                .submitLabel(.done)
                .padding(.vertical, 5)
                .offset(x: 0, y: 35 + offsetY)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(1)) {
                    }
                }
                
            HStack {
                
                Button {
                    print("Tapped apple sign in")
                    authService.startSignInWithAppleFlow()
                } label: {
                    Image("AppleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .frame(width: 50)
                        .offset(x: -25)
                }
                
                Button("Log In") {
                    focusedField = nil // Dismiss keyboard
                    Task { try await viewModel.createUser() }
                }
                .font(Font.custom("Good Times", size: 25))
                .foregroundColor(.white)
                .padding(5)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .background(Color.blue)
                .cornerRadius(10)
                
                Button {
                    print("Tapped google sign in")
                    authService.googleSignIn()
                } label: {
                    Image("GoogleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .frame(width: 50)
                        .offset(x: 25)
                }
            }
            .rotationEffect(.degrees(-12))
            .offset(x: 0 + offsetXSignUpButton, y: 180 + offsetYSignUpButton)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.45)) {
                    offsetXSignUpButton = -400
                    offsetYSignUpButton = 80
                }
            }
            
            HStack {
                
                Button {
                    print("Tapped apple sign in")
                    authService.startSignInWithAppleFlow()
                } label: {
                    Image("AppleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .frame(width: 50)
                        .offset(x: -25)
                }
                
                Button("Sign Up") {
                    focusedField = nil // Dismiss keyboard
                    Task { try await viewModel.createUser() }
                }
                .font(Font.custom("Good Times", size: 25))
                .foregroundColor(.white)
                .padding(5)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .background(Color.blue)
                .cornerRadius(10)
                
                Button {
                    print("Tapped google sign in")
                    authService.googleSignIn()
                } label: {
                    Image("GoogleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .frame(width: 50)
                        .offset(x: 25)
                }
            }
            .rotationEffect(.degrees(-12))
            .offset(x: 100 + offsetX, y: 105 + offsetYLogInButton)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.45)) {
                    offsetX = -100
                    offsetYLogInButton = 75
                }
            }
            
            HStack {
                Text("Don't have an account?")
                    .font(.system(size: 20))
                Button(action: {
                    showLogin = 1
                }) {
                    Text("Sign Up")
                        .font(Font.custom("Good Times", size: 20))
                        .foregroundColor(.blue)
                }
            }
            .rotationEffect(.degrees(-12))
            .offset(x: 0, y: 280 + offsetYSignUp)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    offsetYSignUp = 220
                }
            }
            
            HStack {
                Text("Have an account?")
                    .font(.system(size: 20))
                Button(action: {
                    showLogin = 2
                }) {
                    Text("Log In")
                        .font(Font.custom("Good Times", size: 20))
                        .foregroundColor(.blue)
                }
            }
            .rotationEffect(.degrees(-12))
            .offset(x: 0, y: 500 - offsetYSignUp)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.55)) {
                    offsetYSignUp = 220
                }
            }
        }
        .background(Color("Base"))
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
     
            
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .frame(width: 300, height: 50)
            .padding()
            .foregroundColor(.white)
    }
}
