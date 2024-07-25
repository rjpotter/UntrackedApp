import SwiftUI

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedIndex: Int
    @State private var showAlert = false
    @State private var navigateToAddFriend = false
    @State private var navigateToUploadPost = false
    @State private var navigateBackToRoot = false
    @State private var isRefreshing = false

    init(user: User, selectedIndex: Binding<Int>) {
        self._viewModel = StateObject(wrappedValue: SocialViewModel(user: user))
        self._selectedIndex = selectedIndex
        self.locationManager = LocationManager()
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("Untracked")
                        .font(Font.custom("Good Times", size: 30))
                    HStack {
                        Button(action: {
                            navigateToAddFriend = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.green)
                                .cornerRadius(10)
                        }

                        Spacer()

                        Button(action: {
                            navigateToUploadPost = true
                        }) {
                            Image(systemName: "plus.square")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 2)

                    NavigationLink(destination: AddFriendView().environmentObject(viewModel), isActive: $navigateToAddFriend) {
                        EmptyView() // Hidden NavigationLink
                    }

                    .fullScreenCover(isPresented: $navigateToUploadPost) {
                        TrackHistoryListView(socialViewModel: viewModel, fromSocialPage: true, locationManager: locationManager, isMetric: .constant(false), navigateBackToRoot: $navigateBackToRoot)
                    }

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.posts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })) { post in
                                PostCell(post: post).environmentObject(viewModel)
                            }
                        }
                        .refreshable {
                            refresh()
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .onChange(of: navigateBackToRoot) { newValue in
                if newValue {
                    navigateToUploadPost = false
                    navigateBackToRoot = false
                }
            }
        }
    }

    private func refresh() async {
        isRefreshing = true
        do {
            try await viewModel.fetchPosts()
        } catch {
            print("Error fetching posts: \(error)")
            // Handle error appropriately, maybe show an alert to the user
        }
        isRefreshing = false
    }
}

