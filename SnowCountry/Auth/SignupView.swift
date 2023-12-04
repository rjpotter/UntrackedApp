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
            
            VStack(spacing: 0) {
                Text("SnowCountry")
                    .font(Font.custom("Good Times", size:30))
                    .padding()

                TextField("Username", text: $viewModel.username)
                    .applyTextFieldStyle()

                // Display email error prompt
                if !viewModel.emailError.isEmpty {
                    Text(viewModel.emailError)
                        .foregroundColor(.red)
                       
                }
                TextField("Email", text: $viewModel.email)
                    .applyTextFieldStyle()
                    .onChange(of: viewModel.email) { _ in
                        _ = viewModel.isEmailValid()
                    }

                // Display password error prompt
                if !viewModel.passwordError.isEmpty {
                    Text(viewModel.passwordError)
                        .foregroundColor(.red)
                       
                }
                SecureField("Password", text: $viewModel.password)
                    .applyTextFieldStyle()
                    .onChange(of: viewModel.password) { _ in
                        _ = viewModel.isPasswordValid()
        
                    }
                

                Button("Sign Up") {
                    Task {
                        try await viewModel.createUser()
                    }
                }
               
                .frame(width: 300, height: 60)
                .foregroundColor(Color.white)
                .background(Color.orange)
                .cornerRadius(5)
            }
            .padding(.bottom, 75)
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
