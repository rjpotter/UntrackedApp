import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = SignupViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Shredders")
                .font(.system(size: 40, weight: .bold))
                .padding(.top, 50)  // Add padding to the top instead of offset
            
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(.plain)
                .font(.system(size: 25, weight: .bold))
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.plain)
                .font(.system(size: 25, weight: .bold))
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.plain)
                .font(.system(size: 25, weight: .bold))
            
            Button("Sign Up") {
                Task {
                  try await viewModel.createUser()
                }
            }
            .frame(width: 100, height: 60)
            .foregroundColor(Color.white)
            .background(Color.black)
            .cornerRadius(15)
        }
    }
}
