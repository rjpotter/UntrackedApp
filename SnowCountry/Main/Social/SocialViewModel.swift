import SwiftUI
import Foundation
import FirebaseFirestore

class SocialViewModel: ObservableObject {
    @Published var posts = [Post]()
    
    init() {
        Task {
            try await fetchPosts()
        }
    }
    
    @MainActor
    func fetchPosts() async throws {
        self.posts = try await PostService.fetchAllPosts()
    }
}
