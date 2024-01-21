//
//  ProfileView.swift
//  SnowCountry
//  Created by Ryan Potter on 10/05/23.
//

import SwiftUI
import MapKit

// Custom struct for statistics
struct ProfileStatistic: Hashable {
    let title: String
    let value: String
}

struct ProfileView: View {
    let user: User
    @State private var showEditProfile = false
    @ObservedObject var locationManager = LocationManager()
    @StateObject private var socialViewModel: SocialViewModel
    @State private var tracking = false
    @State private var showAlert = false
    @State private var showTrackHistoryList = false
    @State var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMetric: Bool
    @State private var lifetimeStats = LifetimeStats()
    @State private var trackFiles: [String] = []
    @State private var selectedOption: String = "Lifetime Stats"
    @State private var friendsCount: Int = 0
    @State var showFriendsList = false
    @State var showFriendsRequestList = false
    
    // Initialize trackFiles in the init method
    init(user: User, isMetric: Binding<Bool>) {
        self.user = user
        self._isMetric = isMetric
        self._socialViewModel = StateObject(wrappedValue: SocialViewModel(user: user))
        
        // Retrieve the track filenames and add them to trackFiles
        let trackFilenames = locationManager.getTrackFiles().sorted(by: { $1 > $0 })
        self.trackFiles = trackFilenames
    }
    
    private var statistics: [ProfileStatistic] {
        return isMetric ? metricsStatistics : imperialStatistics
    }
    
    private var metricsStatistics: [ProfileStatistic] {
        return [
            ProfileStatistic(title: "Days", value: "\(lifetimeStats.totalDays)"),
            ProfileStatistic(title: "Vertical", value: "\(lifetimeStats.totalVertical.rounded(toPlaces: 1)) m"),
            ProfileStatistic(title: "Distance", value: "\(lifetimeStats.totalDistance.rounded(toPlaces: 1)) km"),
            ProfileStatistic(title: "Max Speed", value: "\((lifetimeStats.topSpeed).rounded(toPlaces: 1)) km/h"),
            ProfileStatistic(title: "Record Time", value: "\(formattedTime(time: lifetimeStats.totalDuration))")
        ]
    }
    
    private var imperialStatistics: [ProfileStatistic] {
        return [
            ProfileStatistic(title: "Days", value: "\(lifetimeStats.totalDays)"),
            ProfileStatistic(title: "Vertical", value: "\((lifetimeStats.totalVertical * 3.28084).rounded(toPlaces: 1)) ft"),
            ProfileStatistic(title: "Distance", value: "\((lifetimeStats.totalDistance * 0.621371).rounded(toPlaces: 1)) mi"),
            ProfileStatistic(title: "Max Speed", value: "\((lifetimeStats.topSpeed * 0.621371).rounded(toPlaces: 1)) mph"),
            ProfileStatistic(title: "Record Time", value: "\(formattedTime(time: lifetimeStats.totalDuration))")
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
            
            ScrollView {
                VStack {
                    ZStack(alignment: .topLeading) {
                        BannerImage(user: user)
                            .frame(height: 200) // Adjust height as needed

                        VStack(alignment: .leading) {
                            Spacer(minLength: 140) // Reduced minLength for less space above the profile image
                            
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
                                    Button(action: {
                                        isDarkMode.toggle()
                                    }) {
                                        Image(systemName: isDarkMode ? "moon.fill" : "moon")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(isDarkMode ? .blue : .blue)
                                    }
                                    .frame(width: 50, height: 50)
                                    
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
                                        showFriendsRequestList = true
                                    }) {
                                        VStack {
                                            Text("Friend Requests")
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
                            Text("Post Grid Content") // Replace with actual post grid content
                        } else if selectedOption == "Lifetime Stats" {
                            // Lifetime Stats content
                            ProfileStatisticsView(rows: rows, lifetimeStats: lifetimeStats)
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
                        Toggle(isOn: $isMetric) {
                            HStack {
                                Text("Units: ")
                                Text(isMetric ? "Metric" : "Imperial")
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
                                })
                            )
                        }
                    }
                }
            }
            .onAppear {
                loadTrackFiles()
                fetchFriendsCount()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(user: user)
            }
            .fullScreenCover(isPresented: $showTrackHistoryList) {
                TrackHistoryListView(locationManager: locationManager, isMetric: $isMetric)
            }
            
            .sheet(isPresented: $showFriendsList) {
                FriendsListView(socialViewModel: socialViewModel, user: user)
            }
            
            .sheet(isPresented: $showFriendsList) {
                FriendsRequestListView(socialViewModel: socialViewModel, user: user)
            }
        }
        .background(Color("Background").opacity(0.5))
    }
    
    private func loadTrackFiles() {
        let trackFilenames = locationManager.getTrackFiles().sorted(by: { $1 > $0 })
        self.trackFiles = trackFilenames
        updateLifetimeStats() // Now call to update stats
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
    
    private func updateLifetimeStats() {
        var lifetimeMaxSpeed: Double = 0.0
        var uniqueRecordingDates: Set<Date> = []
        
        // Reset lifetimeStats to zero before recalculating
        lifetimeStats = LifetimeStats()
        
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let calendar = Calendar.current
        
        for fileName in trackFiles {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            guard let fileContents = try? String(contentsOf: fileURL) else {
                continue
            }
            let locations = GPXParser.parseGPX(fileContents)
            
            if let firstLocation = locations.first {
                let date = calendar.startOfDay(for: firstLocation.timestamp)
                uniqueRecordingDates.insert(date)
            }
            
            let distance = calculateTotalDistance(locations: locations, isMetric: !isMetric)
            let maxElevation = calculateMaxElevation(locations: locations, isMetric: !isMetric)
            let duration = calculateDuration(locations: locations)
            let maxSpeed = calculateMaxSpeed(locations: locations, isMetric: !isMetric)
            let vertical = calculateTotalElevationLoss(locations: locations, isMetric: !isMetric)
            
            // Update lifetimeStats properties
            lifetimeStats.totalDistance += distance
            lifetimeStats.maxElevation = max(lifetimeStats.maxElevation, maxElevation)
            lifetimeStats.totalDuration += duration
            lifetimeStats.totalVertical += vertical
            lifetimeMaxSpeed = max(lifetimeMaxSpeed, maxSpeed)
        }
        
        // Set the lifetime maximum speed after processing all tracks
        lifetimeStats.topSpeed = lifetimeMaxSpeed
        
        // Update the total number of unique recording days
        lifetimeStats.totalDays = uniqueRecordingDates.count
    }
    
    private func formattedTime(time: TimeInterval) -> String {
        let seconds = Int(time)
        
        let days = seconds / 86400 // 86400 seconds in a day
        let hours = (seconds % 86400) / 3600 // Remaining hours after calculating days
        
        var timeString = ""
        
        if days > 0 {
            timeString += "\(days) day\(days == 1 ? "" : "s")"
        }
        
        if hours > 0 {
            if !timeString.isEmpty {
                timeString += " "
            }
            timeString += "\(hours) hr"
        }
        
        return timeString.isEmpty ? "0 hr" : timeString
    }
}

// Custom Label Style
struct IconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .font(.headline)
            configuration.title
        }
        .padding()
        .background(Color.secondary.opacity(0.3))
        .foregroundColor(Color.primary)
        .cornerRadius(10)
    }
}

extension LocationManager {
    func deleteTrackFile(named fileName: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Deleted file:", fileName)
        } catch {
            print("Could not delete file: \(error)")
        }
    }
}

extension Color {
    static let systemBackground = Color(UIColor.secondarySystemBackground)
}

struct ProfileStatisticCard: View {
    let statistic: ProfileStatistic
    var icon: String? = nil
    var iconColor: Color = .secondary

    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconForStatistic(statistic.title))
                    .foregroundColor(colorForStatistic(statistic.title))
                Text(statistic.title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text(statistic.value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                if let iconName = icon {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                }
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(10)
    }

    func iconForStatistic(_ title: String) -> String {
        switch title {
        case "Max Speed":
            return "gauge.with.dots.needle.100percent"
        case "Distance":
            return "map"
        case "Max Elevation", "Min Elevation", "Total Vertical", "Altitude", "Vertical":
            return "mountain.2.circle"
        case "Duration", "Record Time":
            return "clock"
        case "Days":
            return "calendar.circle"
        default:
            return "questionmark.circle"
        }
    }

    func colorForStatistic(_ title: String) -> Color {
        switch title {
        case "Max Speed":
            return .blue
        case "Distance":
            return .green
        case "Max Elevation", "Min Elevation", "Total Vertical", "Altitude", "Vertical":
            return .orange
        case "Duration":
            return .purple
        case "Days", "Record Time":
            return .red
        default:
            return .gray
        }
    }
}

