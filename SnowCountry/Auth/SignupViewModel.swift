import Foundation

class SignupViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var emailError = ""
    @Published var passwordError = ""
    
    
    
    func isEmailValid() -> Bool {
         if email.contains("@") {
             emailError = ""
             return true
         } else {
             emailError = "*Must be a valid email*"
             return false
         }
     }
     
     func isPasswordValid() -> Bool {
         if password.count >= 8 {
             passwordError = ""
             return true
         } else {
             passwordError = "*Password must be over 8 characters*"
             return false
         }
     }
    
    
    func createUser() async throws {
        try await AuthService.shared.createUser(username, email, password)
        
        username = ""
        email = ""
        password = ""
        
        
        
        
    }
}
