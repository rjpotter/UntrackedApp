//
//  FriendProfileView.swift
//  SnowCountry
//  Created by Ryan Potter on 1/30/24.
//

import SwiftUI
import MapKit

struct FriendProfileView: View {
    let user: User
    @ObservedObject var locationManager = LocationManager()
    @StateObject private var socialViewModel: SocialViewModel
    @State private var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMetric: Bool
    @State private var lifetimeStats = LifetimeStats()
    @State private var friendsCount: Int = 0
    @State private var showFriendsList = false
    @State private var selectedOption: String = "Post Grid" // Default option
    @ObservedObject var profileViewModel: ProfileViewModel

    init(forFriend user: User, isMetric: Binding<Bool>, locationManager: LocationManager, userSettings: UserSettings) {
        self.user = user
        self._isMetric = isMetric
        _profileViewModel = ObservedObject(wrappedValue: ProfileViewModel(user: user, locationManager: locationManager, userSettings: userSettings))
        self._socialViewModel = StateObject(wrappedValue: SocialViewModel(user: user))
    }    
    
    private var statistics: [ProfileStatistic] {
        return isMetric ? metricsStatistics : imperialStatistics
    }
    
    private var metricsStatistics: [ProfileStatistic] {
        return [
            ProfileStatistic(title: "Days", value: "TBA"),
            ProfileStatistic(title: "Vertical", value: "0 m"),
            ProfileStatistic(title: "Distance", value: "0 km"),
            ProfileStatistic(title: "Max Speed", value: "0 km/h"),
            ProfileStatistic(title: "Record Time", value: "TBA")
        ]
    }

    private var imperialStatistics: [ProfileStatistic] {
        return [
            ProfileStatistic(title: "Days", value: "TBA"),
            ProfileStatistic(title: "Vertical", value: "0 ft"),
            ProfileStatistic(title: "Distance", value: "0 mi"),
            ProfileStatistic(title: "Max Speed", value: "0 mph"),
            ProfileStatistic(title: "Record Time", value: "TBA")
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
        VStack {
            Text("SnowCountry")
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
                                Spacer(minLength: 120)
                                
                                ProfileImage(user: user, size: ProfileImageSize.large)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                                    .offset(x: 15)
                                
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
                                        
                                        Spacer()
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
                                    //Text("Post Grid Content")
                                } else if selectedOption == "Lifetime Stats" {
                                    ProfileStatisticsView(user: user, rows: rows, profileViewModel: profileViewModel)
                                        .id(UUID())
                                } else if selectedOption == "Track History" {
                                    Text("Track History Content")
                                }
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                        }
                    }
                }
            }
            
            NavigationLink(destination: FriendsListView(isMetric: isMetric, user: user).environmentObject(socialViewModel), isActive: $showFriendsList) {
                EmptyView() // Hidden NavigationLink
            }
            
            .onAppear {
                fetchFriendsCount()
            }

            .preferredColorScheme(isDarkMode ? .dark : .light)
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
