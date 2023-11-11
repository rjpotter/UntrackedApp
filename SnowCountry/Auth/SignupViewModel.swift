import Foundation

class SignupViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    
    func createUser() async throws {
        try await AuthService.shared.createUser(username, email, password)
        
        username = ""
        email = ""
        password = ""
    }
}
