//SignupViewModel.swift

import Foundation

class SignupViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var emailError = ""
    @Published var passwordError = ""
    
    
    
    func isEmailValid(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)

        if emailTest.evaluate(with: email) {
            emailError = ""
            return true
        } else {
            emailError = "*Must be a valid email*"
            return false
        }
    }
     
    func isPasswordValid(password: String) -> Bool {
        // Check if the password length is at least 8 characters
        guard password.count >= 8 else {
            passwordError = "*Password must be at least 8 characters*"
            return false
        }
        
        // Check for the presence of at least one uppercase letter
        guard password.rangeOfCharacter(from: .uppercaseLetters) != nil else {
            passwordError = "*Password must include at least one uppercase letter*"
            return false
        }

        // Check for the presence of at least one lowercase letter
        guard password.rangeOfCharacter(from: .lowercaseLetters) != nil else {
            passwordError = "*Password must include at least one lowercase letter*"
            return false
        }

        // Check for the presence of at least one digit
        guard password.rangeOfCharacter(from: .decimalDigits) != nil else {
            passwordError = "*Password must include at least one number*"
            return false
        }

        // Check for the presence of at least one special character
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[{}]|;:'\",<.>/?")
        guard password.rangeOfCharacter(from: specialCharacterSet) != nil else {
            passwordError = "*Password must include at least one special character*"
            return false
        }

        // If all conditions are met
        passwordError = ""
        return true
    }

    
    @MainActor
    func createUser() async throws {
        try await AuthService.shared.createUser(username, email, password)
        
        username = ""
        email = ""
        password = ""
    }
}
