//LoginViewModel.swift

import Foundation
import AuthenticationServices

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String? = nil

    func signIn() async {
        do {
            try await AuthService.shared.login(withEmail: email, password)
            DispatchQueue.main.async {
                self.errorMessage = nil // Clear any existing error message
            }
        } catch {
            DispatchQueue.main.async {
                // Assuming 'error' contains the information about the login failure
                // Update the message as per your requirements
                self.errorMessage = "Failed to login user with error: An internal error has occurred, print and inspect the error details for more information."
            }
        }
    }
}


