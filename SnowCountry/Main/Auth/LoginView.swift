// LoginView.swift

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @FocusState private var focusedField: FocusField?
    @EnvironmentObject var authService: AuthService
    @State private var rotationAngle: Double = -12
    @State private var offsetY: Double = 0
    @State private var offsetYSignUp: Double = 0
    @State private var offsetYLogInButton: Double = 0
    @State private var offsetYSignUpButton: Double = 0
    @State private var offsetX: Double = 250
    @State private var offsetXSignUpButton: Double = 0
    @State private var boxOpacity: Double = 0.0
    @State private var offsetXUserNameBox: Double = 0
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
            
            if showLogin == 2 {
                // Username Box Background
                Rectangle()
                    .frame(width: 750, height: 50)
                    .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                    .cornerRadius(30)
                    .offset(x: -100 + offsetXUserNameBox, y: -70)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            offsetXUserNameBox = 1000
                        }
                    }
                
                // Email Box Background
                Rectangle()
                    .frame(width: 750, height: 50)
                    .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                    .cornerRadius(30)
                    .offset(x: -100, y: 0 - offsetY)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            rotationAngle = 0
                            offsetY = 35
                        }
                    }
                
                // Password Box Background
                Rectangle()
                    .frame(width: 750, height: 50)
                    .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                    .cornerRadius(30)
                    .offset(x: -100, y: 70 - offsetY)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            rotationAngle = 0
                            offsetY = 35
                        }
                    }
            }
            
            if showLogin == 0 {
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
            
            if showLogin == 2 {
                // Username Field
                TextField("Username", text: $viewModel.email)
                    .applyTextFieldStyle()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .username)
                    .padding(.vertical, 5)
                    .offset(x: 0 + offsetXUserNameBox, y: -70)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
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
                    .offset(x: 0, y: 0 - offsetY)
                    .opacity(boxOpacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            boxOpacity = 1.0
                        }
                    }
                
                SecureField("Password", text: $viewModel.password)
                    .applyTextFieldStyle()
                    .focused($focusedField, equals: .password)
                    .textContentType(.password)
                    .submitLabel(.done)
                    .padding(.vertical, 5)
                    .offset(x: 0, y: 70 - offsetY)
                    .opacity(boxOpacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            boxOpacity = 1.0
                        }
                    }
            }
            
            if showLogin ==  0 {
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
            }
            
            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            
            if showLogin == 0 {
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
                        Task { try await viewModel.signIn() }
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
                .offset(x: 0, y: 500 - offsetYSignUp)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(0.45)) {
                        offsetYSignUp = 220
                    }
                }
            }
            if showLogin == 2 {
                
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
                        Task { try await viewModel.signIn() }
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
                    Text("Have an account?")
                        .font(.system(size: 20))
                    Button(action: {
                        showLogin = 1
                    }) {
                        Text("Log In")
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
                .offset(x: 0, y: 500 - offsetYSignUp)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(0.55)) {
                        offsetYSignUp = 220
                    }
                }
            }
        }
        .background(Color("Base"))
    }
}

enum FocusField {
    case username, email, password
}
