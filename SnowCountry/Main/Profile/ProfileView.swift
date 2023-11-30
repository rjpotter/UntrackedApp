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
    @State var isDarkMode = false
    
    var body: some View {
        NavigationView {
            List {
                ZStack(alignment: .leading) {
                    // banner image, I want to change it so it can be edited like the profile image
                    Image("testBannerImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                    
                    // profile image, style is stored in components
                    ProfileImage(user: user, size: ProfileImageSize.large)
                    //.offset(x:80, y: -150)
                        .offset(x:60, y: 60)
                    
                    // username
                    HStack() {
                        Text(user.username)
                        
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                        
                        //.offset(x:80, y: -155)
                            .offset(x:65,  y: 170)
                        
                    }
                    
                //DARK MODE BUTTON
                HStack(){
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "moon.fill" : "moon")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .trailing)
                            .foregroundColor(isDarkMode ? .blue : .blue)
                            .clipped().buttonStyle(BorderlessButtonStyle())
                            .fixedSize()
                            .padding(.leading, 50)
                        
                        
                        
                        
                        
                    } .buttonStyle(ClippedButtonStyle())
                    //.offset( x: 200, y: -205)
                        .offset( x: 185,   y: 217)
                }
            
                // EDIT PROFILE BUTTON
                VStack(alignment: .leading) {
                    Button(action: {
                        showEditProfile.toggle()
                    }) {
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 150, height: 50)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                                .overlay(
                                    Text("Edit Profile")
                                        .font(.system(size: 15))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.black)
                                )
                            
                        }
                        .frame(width: 100, height: 60)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                    .offset(x: -25, y: 217)
                    .offset(x: 100)
                    .padding()
            }
            .padding(.top, -12)
            .padding(.bottom, 150)
                
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
                
                // TrackViewMap to show the tracking on the map
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
            .background(Color(UIColor.systemBackground))
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationTitle("User Profile")
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(user: user)
                
            }
        }
        .padding(.leading, -20)
        .padding(.trailing, -20)
    }
}

// added this function so the buttons can only be pressed within there shape
struct ClippedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
        
    }
}


