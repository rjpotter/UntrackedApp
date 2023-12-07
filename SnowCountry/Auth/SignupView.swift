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
                Text("SnowCountry")
                    .font(Font.custom("Good Times", size:30))
                    .offset(y: -40)
                    .foregroundColor(.white)

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
                        .foregroundColor(.red)
                       
                }
                TextField("", text: $viewModel.email)
                    .applyTextFieldStyle()
                    .onChange(of: viewModel.email) { _ in
                        _ = viewModel.isEmailValid()
                    }
                    .padding(.vertical, 10)
                
                Text("Password:")
                    .foregroundColor(.white)
                // Display password error prompt
                if !viewModel.passwordError.isEmpty {
                    Text(viewModel.passwordError)
                        .foregroundColor(.red)
                       
                }
                SecureField("", text: $viewModel.password)
                    .applyTextFieldStyle()
                    .onChange(of: viewModel.password) { _ in
                        _ = viewModel.isPasswordValid()
        
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
