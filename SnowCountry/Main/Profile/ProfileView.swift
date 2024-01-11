//
//  ProfileView.swift
//  ArcGIS-Test
//  Created by Ryan Potter on 10/05/23.

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

    private var statistics: [Statistic] {
        isMetric ? metricsStatistics : imperialStatistics
    }

    private var metricsStatistics: [Statistic] {
        let speedInKmh = Double(0 * 3.6) // Example conversion
        let distanceInKilometers = Double(0 / 1000) // Example conversion
        let verticalInMeters = Double(0)

        return [
            Statistic(title: "Days", value: "X"),
            Statistic(title: "Vertical", value: "\(verticalInMeters.rounded(toPlaces: 1)) m"),
            Statistic(title: "Distance", value: "\(distanceInKilometers.rounded(toPlaces: 1)) km"),
            Statistic(title: "Max Speed", value: "\(speedInKmh.rounded(toPlaces: 1)) km/h"),
            Statistic(title: "Record Time", value: "X Hours")
        ]
    }

    private var imperialStatistics: [Statistic] {
        let speedInMph = Double(0 * 2.23694) // Example conversion
        let distanceInMiles = Double(0 * 0.000621371) // Example conversion
        let verticalInFeet = Double(0 * 3.28084) // Example conversion

        return [
            Statistic(title: "Days", value: "X"),
            Statistic(title: "Vertical", value: "\(verticalInFeet.rounded(toPlaces: 1)) ft"),
            Statistic(title: "Distance", value: "\(distanceInMiles.rounded(toPlaces: 1)) mi"),
            Statistic(title: "Max Speed", value: "\(speedInMph.rounded(toPlaces: 1)) mph"),
            Statistic(title: "Record Time", value: "X Hours")
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
                            .offset(x: 70, y: 70)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack{
                                Text(user.username)
                                    .font(.system(size: 25))
                                    .fontWeight(.semibold)
                                    .offset(x: 65, y: 200)
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
                                .offset(x: 65, y: 200)
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
                            .offset(x: 65, y: 200)
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
                        ProfileStatisticsView(rows: rows)
                    }
                    .frame(maxWidth: (UIScreen.main.bounds.width - 20))
                    .padding(.top, 10)
                    
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
            .background(Color("Background").opacity(0.5))
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
