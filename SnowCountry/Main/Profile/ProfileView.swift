//
//  ProfileView.swift
//  SnowCountry
//  Created by Ryan Potter on 10/05/23.
//

import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    let user: User
    @State private var showEditProfile = false
    @ObservedObject var locationManager: LocationManager
    @StateObject private var socialViewModel: SocialViewModel
    @EnvironmentObject var authService: AuthService
    @State private var tracking = false
    @State private var showAlert = false
    @State private var showTrackHistoryList = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userSettings: UserSettings
    @State private var lifetimeStats = LifetimeStats()
    @State private var trackFiles: [String] = []
    @State private var selectedOption: String = "Lifetime Stats"
    @State private var friendsCount: Int = 0
    @State private var invitesCount: Int = 0
    @State private var activeSheet: ActiveSheet?
    @State private var showFriendsList = false
    @State private var showRequestsList = false
    @ObservedObject var profileViewModel: ProfileViewModel
    
    init(user: User) {
        self.user = user
        let locationManager = LocationManager()
        let userSettings = UserSettings() // Ensure you have access to user settings here, possibly passed in or accessed differently if needed

        // First, initialize dependencies directly
        _locationManager = ObservedObject(wrappedValue: locationManager)
        
        // Then, initialize ProfileViewModel with the dependencies
        _profileViewModel = ObservedObject(wrappedValue: ProfileViewModel(user: user, locationManager: locationManager, userSettings: userSettings))
        
        // Finally, initialize any other view models
        _socialViewModel = StateObject(wrappedValue: SocialViewModel(user: user))
        
        let trackFilenames = locationManager.getTrackFiles().sorted(by: { $1 > $0 })
        _trackFiles = State(initialValue: trackFilenames)
    }

    private var statistics: [ProfileStatistic] {
        userSettings.isMetric ? metricsStatistics : imperialStatistics
    }
    
    private var metricsStatistics: [ProfileStatistic] {
        [
            ProfileStatistic(title: "Days", value: "\(lifetimeStats.totalDays)"),
            ProfileStatistic(title: "Vertical", value: "\(lifetimeStats.totalDownVertical.rounded(toPlaces: 1)) m"),
            ProfileStatistic(title: "Distance", value: "\(lifetimeStats.totalDownDistance.rounded(toPlaces: 1)) km"),
            ProfileStatistic(title: "Max Speed", value: "\((lifetimeStats.topSpeed).rounded(toPlaces: 1)) km/h"),
            ProfileStatistic(title: "Record Time", value: profileViewModel.formattedTime(time: lifetimeStats.totalDuration))
        ]
    }
    
    private var imperialStatistics: [ProfileStatistic] {
        [
            ProfileStatistic(title: "Days", value: "\(lifetimeStats.totalDays)"),
            ProfileStatistic(title: "Vertical", value: "\((lifetimeStats.totalDownVertical * 3.28084).rounded(toPlaces: 1)) ft"),
            ProfileStatistic(title: "Distance", value: "\((lifetimeStats.totalDownDistance * 0.621371).rounded(toPlaces: 1)) mi"),
            ProfileStatistic(title: "Max Speed", value: "\((lifetimeStats.topSpeed * 0.621371).rounded(toPlaces: 1)) mph"),
            ProfileStatistic(title: "Record Time", value: profileViewModel.formattedTime(time: lifetimeStats.totalDuration))
        ]
    }
    
    private var rows: [[ProfileStatistic]] {
        var rows: [[ProfileStatistic]] = []
        var currentRow: [ProfileStatistic] = []
        
        for statistic in statistics {
            if currentRow.count < 2 {
                currentRow.append(statistic)
            } else {
                rows.append(currentRow)
                currentRow = [statistic]
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Untracked")
                    .font(Font.custom("Good Times", size: 30))
                ZStack(alignment: .topLeading) {
                    BannerImage(user: user)
                        .frame(height: 200)
                    ScrollView {
                        ZStack {
                            Rectangle()
                                .fill(Color(.systemBackground))
                                .offset(y: 200)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            VStack {
                                VStack(alignment: .leading) {
                                    Spacer(minLength: 120) // Reduced minLength for less space above the profile image
                                    
                                    ProfileImage(user: user, size: ProfileImageSize.large)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 10)
                                        .offset(x: 15) // Adjusted offset for less vertical space
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(user.username)
                                                .font(.system(size: 25))
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                showFriendsList = true
                                            }) {
                                                VStack {
                                                    Text("Friends")
                                                        .font(.headline)
                                                        .foregroundColor(.secondary)
                                                    Text("\(friendsCount)")
                                                        .font(.title3)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.primary)
                                                }
                                            }
                                            
                                            Button(action: {
                                                showRequestsList = true
                                            }) {
                                                VStack {
                                                    Text("Requests")
                                                        .font(.headline)
                                                        .foregroundColor(.secondary)
                                                    Text("\(invitesCount)")
                                                        .font(.title3)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.primary)
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.leading)
                                        
                                        HStack(spacing: 10) {
                                            Button(action: {
                                                showEditProfile.toggle()
                                            }) {
                                                Label("Edit Profile", systemImage: "pencil")
                                                    .labelStyle(IconLabelStyle())
                                            }
                                            
                                            Button(action: {
                                                showTrackHistoryList = true
                                            }) {
                                                Label("View Track History", systemImage: "map")
                                                    .labelStyle(IconLabelStyle())
                                            }
                                        }
                                        .padding(.leading)
                                    }
                                }
                                
                                // Menu Options
                                HStack {
                                    Button(action: {
                                        selectedOption = "Post Grid"
                                    }) {
                                        Image(systemName: "squareshape.split.2x2")
                                            .imageScale(.large)
                                    }
                                    .foregroundColor(selectedOption == "Post Grid" ? .blue : .gray)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedOption = "Lifetime Stats"
                                    }) {
                                        Image(systemName: "chart.bar.fill")
                                            .imageScale(.large)
                                    }
                                    .foregroundColor(selectedOption == "Lifetime Stats" ? .blue : .gray)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedOption = "Track History"
                                    }) {
                                        Image(systemName: "map.fill")
                                            .imageScale(.large)
                                    }
                                    .foregroundColor(selectedOption == "Track History" ? .blue : .gray)
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width - 200))
                                .padding()
                    
                                Divider()
                                
                                // Content based on selection
                                Group {
                                    if selectedOption == "Post Grid" {
                                        // Post Grid content
                                        //Text("Post Grid Content") // Replace with actual post grid content
                                    } else if selectedOption == "Lifetime Stats" {
                                        // Lifetime Stats content
                                        ProfileStatisticsView(user: user, rows: rows, profileViewModel: profileViewModel)
                                            .id(UUID())
                                    } else if selectedOption == "Track History" {
                                        // Track History content
                                        Text("Track History Content") // Replace with actual track history content
                                    }
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                                
                                Section(header:
                                            HStack {
                                    Text("Settings")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                                    .padding(.top, 10)
                                ) {
                                    Toggle(isOn: $userSettings.isMetric) {
                                        HStack {
                                            Text("Units: ")
                                            Text(userSettings.isMetric ? "Metric" : "Imperial")
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                                    .background(
                                        RoundedRectangle(cornerRadius: 10) // Use RoundedRectangle for the background
                                            .fill(Color.secondary.opacity(0.3))
                                    )
                                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                                    
                                    Button(action: {
                                        showAlert = true
                                    }) {
                                        Text("Logout")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.red.opacity(0.8))
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    }
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                                    .alert(isPresented: $showAlert) {
                                        Alert(
                                            title: Text("Log Out"),
                                            message: Text("Are you sure you want to log out?"),
                                            primaryButton: .default(Text("Cancel")),
                                            secondaryButton: .destructive(Text("Log Out"), action: {
                                                AuthService.shared.signOut()
                                                authService.googleSignOut()
                                            })
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    profileViewModel.fetchLifetimeStatsFromFirebase {
                    }
                    self.fetchFriendsCount()
                    Task {
                        do {
                            let inviteCount = try await socialViewModel.fetchInvitesCount()
                            self.invitesCount = inviteCount
                        } catch {
                            print("Error fetching invites count: \(error)")
                        }
                    }
                }
                
                .fullScreenCover(isPresented: $showEditProfile) {
                    EditProfileView(user: user)
                }
                .fullScreenCover(isPresented: $showTrackHistoryList) {
                    TrackHistoryListView(socialViewModel: socialViewModel, fromSocialPage: false, locationManager: locationManager, isMetric: $userSettings.isMetric)
                }
                
                NavigationLink(destination: FriendsListView(isMetric: userSettings.isMetric, user: user).environmentObject(socialViewModel), isActive: $showFriendsList) {
                    EmptyView() // Hidden NavigationLink
                }
                NavigationLink(destination: FriendRequestsView(socialViewModel: socialViewModel, user: user), isActive: $showRequestsList) {
                    EmptyView() // Hidden NavigationLink
                }
            }
        }
    }
    
    private func fetchFriendsCount() {
        Task {
            do {
                let count = try await socialViewModel.fetchFriendsCount()
                self.friendsCount = count
            } catch {
                print("Error fetching friends count: \(error)")
            }
        }
    }
}

/*
#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(id: "BuYPNxViMOMAWwbZTwwWsNDviUt1", username: "RPotts115", email: "ryanjpotter1@gmail.com")
        let locationManager = LocationManager()
        let userSettings = UserSettings()
        let socialViewModel = SocialViewModel(user: user)
        let profileViewModel = ProfileViewModel(user: user, locationManager: locationManager, userSettings: userSettings)

        return ProfileView(user: user)
            .environmentObject(AuthService())
            .environmentObject(userSettings)
            .environmentObject(socialViewModel)
            .environmentObject(profileViewModel)
    }
}
#endif
*/
