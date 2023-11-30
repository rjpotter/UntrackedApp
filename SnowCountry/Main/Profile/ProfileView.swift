//
//  ProfileView.swift
//  ArcGIS-Test
//
//  Created by Ryan Potter on 10/05/23.

import SwiftUI
import MapKit

struct ProfileView: View {
    let user: User
    @State private var showEditProfile = false
    @ObservedObject var locationManager = LocationManager()
    @State private var trackViewMap = MKMapView()
    @State private var trackHistoryViewMap = MKMapView()
    @State private var tracking = false
    @State private var historyMap = false
    @State private var selectedTrackFile: String?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Profile Details")) {
                    HStack {
                        ProfileImageView(user: user)
                        Text(user.username)
                    }
                    Button("Edit Profile") {
                        showEditProfile.toggle()
                    }
                }
                
                // Button to toggle location tracking
                Button(action: {
                    self.tracking.toggle()
                    if self.tracking {
                        self.locationManager.startTracking()
                    } else {
                        self.locationManager.stopTracking()
                    }
                }) {
                    Text(tracking ? "Stop Tracking" : "Start Tracking")
                }
                
                // TraclViewMap to show the tracking on the map
                if tracking {
                    TrackViewMap(trackViewMap: $trackViewMap, locations: locationManager.locations)
                        .frame(height: 300) // Set a fixed height for the map view
                        .listRowInsets(EdgeInsets()) // Make the map view full-width
                }

                
                Section(header: Text("Run History")) {
                    ScrollView(.horizontal, showsIndicators: true) {
                        VStack {
                            ForEach(locationManager.getTrackFiles(), id: \.self) { fileName in
                                Button(action: {
                                    selectedTrackFile = historyMap ? nil : fileName
                                    print("Selected file: \(fileName)")
                                    historyMap.toggle()
                                }) {
                                    Text(historyMap && selectedTrackFile == fileName ? "Close \(fileName)" : "View \(fileName)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .alignmentGuide(.leading) { _ in 0 } // Align text to the left
                                }
                            }
                        }
                    }
                }

                // Conditional view to display the track map
                if let trackFile = selectedTrackFile, historyMap {
                    // Use TrackHistoryView here, passing the selected track file
                    TrackHistoryView(trackFile: trackFile)
                        .frame(height: 300)
                }

                Section(header: Text("Settings")) {
                    Button("Logout", action: AuthService.shared.signOut)
                        .accentColor(.red)
                }
            }
            .navigationTitle("Profile")
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(user: user)
            }
        }
    }
}
