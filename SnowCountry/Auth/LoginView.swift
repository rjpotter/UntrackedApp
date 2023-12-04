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
                VStack(spacing: 0) {
                    Text("SnowCountry")
                        .font(Font.custom("Good Times", size:30))
                        .padding()

                    TextField("Email", text: $viewModel.email)
                        .applyTextFieldStyle()
                    SecureField("Password", text: $viewModel.password)
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
                    
                }
            }
        }
        .accentColor(.orange)
    }
}
