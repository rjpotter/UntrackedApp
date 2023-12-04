import SwiftUI

@MainActor
class AddFriendViewModel: ObservableObject {
    @Published var user: User
    @Published var users = [User]()
    
    init(user: User) {
        self.user = user
        
        Task { try await fetchAllUsers() }
    }
    
    @MainActor
    func fetchAllUsers() async throws {
        self.users = try await UserService.fetchAllUsers()
    }
}
