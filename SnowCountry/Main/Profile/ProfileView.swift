//
//  ProfileView.swift
//  SnowCountry
//  Created by Ryan Potter on 10/05/23.
//

import SwiftUI
import MapKit

struct ProfileView: View {
    let user: User
    @State private var showEditProfile = false
    @ObservedObject var locationManager = LocationManager()
    @State private var tracking = false
    @State private var showAlert = false
    @State private var showTrackHistoryList = false
    @State var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMetric: Bool
    @State private var lifetimeStats = LifetimeStats()
    @State private var trackFiles: [String] = []
    
    // Initialize trackFiles in the init method
    init(user: User, isMetric: Binding<Bool>) {
        self.user = user
        self._isMetric = isMetric
        
        // Retrieve the track filenames and add them to trackFiles
        let trackFilenames = locationManager.getTrackFiles().sorted(by: { $1 > $0 })
        self.trackFiles = trackFilenames
    }
    
    private var statistics: [Statistic] {
        return isMetric ? metricsStatistics : imperialStatistics
    }
    
    private var metricsStatistics: [Statistic] {
        return [
            Statistic(title: "Days", value: "\(lifetimeStats.totalDays)"),
            Statistic(title: "Vertical", value: "\(lifetimeStats.totalVertical.rounded(toPlaces: 1)) m"),
            Statistic(title: "Distance", value: "\(lifetimeStats.totalDistance.rounded(toPlaces: 1)) km"),
            Statistic(title: "Max Speed", value: "\((lifetimeStats.topSpeed).rounded(toPlaces: 1)) km/h"),
            Statistic(title: "Record Time", value: "\(formattedTime(time: lifetimeStats.totalDuration))")
        ]
    }
    
    private var imperialStatistics: [Statistic] {
        return [
            Statistic(title: "Days", value: "\(lifetimeStats.totalDays)"),
            Statistic(title: "Vertical", value: "\((lifetimeStats.totalVertical * 3.28084).rounded(toPlaces: 1)) ft"),
            Statistic(title: "Distance", value: "\((lifetimeStats.totalDistance * 0.621371).rounded(toPlaces: 1)) mi"),
            Statistic(title: "Max Speed", value: "\((lifetimeStats.topSpeed * 0.621371).rounded(toPlaces: 1)) mph"),
            Statistic(title: "Record Time", value: "\(formattedTime(time: lifetimeStats.totalDuration))")
        ]
    }
    
    private var rows: [[Statistic]] {
        var rows: [[Statistic]] = []
        var currentRow: [Statistic] = []
        
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
                    ZStack(alignment: .leading) {
                        BannerImage(user: user)
                        ProfileImage(user: user, size: ProfileImageSize.large)
                            .offset(x: 15, y: 70)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack{
                                Text(user.username)
                                    .font(.system(size: 25))
                                    .fontWeight(.semibold)
                                    .offset(x: 5, y: 200)
                                    .padding(.leading)
                                
                                Button(action: {
                                    isDarkMode.toggle()
                                }) {
                                    Image(systemName: isDarkMode ? "moon.fill" : "moon")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(isDarkMode ? .blue : .blue)
                                }
                                .frame(width: 50, height: 50)
                                .offset(x: 10, y: 200)
                            }
                            
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
                            .offset(x: 10, y: 200)
                            .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                        }
                    }
                    .padding(.top, -12)
                    .padding(.bottom, 150)
                    
                    Section(header:
                                HStack {
                        Text("Lifetime Stats")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                        .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                        .padding(.top, 10)
                    ) {
                        
                        // Statistics Grid
                        ProfileStatisticsView(rows: rows, lifetimeStats: lifetimeStats)
                            .id(UUID())
                    }
                    .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                    .padding(.top, 10)
                    .onAppear {
                        loadTrackFiles()
                    }
                    
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
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(user: user)
            }
            .fullScreenCover(isPresented: $showTrackHistoryList) {
                TrackHistoryListView(locationManager: locationManager, isMetric: $isMetric)
            }
        }
        .background(Color("Background").opacity(0.5))
    }
    
    private func loadTrackFiles() {
        let trackFilenames = locationManager.getTrackFiles().sorted(by: { $1 > $0 })
        self.trackFiles = trackFilenames
        updateLifetimeStats() // Now call to update stats
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
