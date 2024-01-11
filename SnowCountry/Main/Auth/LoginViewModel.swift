//LoginViewModel.swift

import Foundation
import AuthenticationServices

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signIn() async throws {
        try await AuthService.shared.login(withEmail: email, password)
    }
    /*
    func signInWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self // Make sure your ViewModel conforms to `ASAuthorizationControllerDelegate`
        controller.performRequests()
    }


    func signInWithGoogle() {
        // Implement Google Sign-In
    }
     */
}

