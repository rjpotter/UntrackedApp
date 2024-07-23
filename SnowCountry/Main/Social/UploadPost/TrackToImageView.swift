//
//  TrackToImageView.swift
//  SnowCountry
//  Created by Ryan Potter on 3/06/24.
//

import SwiftUI
import MapKit

enum MapStyle: String, CaseIterable {
    case normal = "Normal"
    case satellite = "Satellite"
    case hybrid = "3D Hybrid"
}

struct TrackToImageView: View {
    var trackURL: URL
    var trackName: String
    var user: User // Add user property
    @State private var trackDate: String = ""
    @State private var selectedMapStyle: MapStyle = .normal
    @State private var locations: [CLLocation] = []
    @State private var maxSpeed: Double = 0.0
    @State private var totalDescent: Double = 0.0
    @State private var maxElevation: Double = 0.0
    @State private var totalDescentDistance: Double = 0.0
    @StateObject private var locationManager = LocationManager()
    @State private var showSaveAlert = false
    private let mapView = MKMapView()

    var body: some View {
        VStack {
            Text(trackName)
                .font(.headline)
                .padding()

            ZStack {
                TrackImageMapView(locations: locations, selectedMapStyle: $selectedMapStyle)
                    .frame(height: 330)
                    .cornerRadius(15)
                    .padding()

                TrackMapStats(
                    selectedMapStyle: selectedMapStyle,
                    maxSpeed: maxSpeed,
                    totalDescent: totalDescent,
                    maxElevation: maxElevation,
                    totalDescentDistance: totalDescentDistance,
                    trackDate: trackDate,
                    username: user.username // Pass username to stats
                )
                    .frame(height: 290)
            }
            .frame(maxWidth: .infinity)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(MapStyle.allCases, id: \.self) { style in
                        MapStyleButton(style: style, isSelected: selectedMapStyle == style) {
                            selectedMapStyle = style
                        }
                    }
                }
            }
            
            Button(action: {
                TrackToImageViewModel.generateAndSaveImage(
                    track: createPolyline(from: locations),
                    mapType: mapType(from: selectedMapStyle),
                    username: user.username,
                    maxSpeed: maxSpeed,
                    totalDescent: totalDescent,
                    maxElevation: maxElevation,
                    totalDescentDistance: totalDescentDistance,
                    trackDate: trackDate,
                    mapStyle: selectedMapStyle,
                    size: CGSize(width: 375, height: 667)
                )
            }) {
                Text("Next")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(10)
        .navigationTitle("Upload Post")
        .onAppear {
            loadTrackData()
        }
    }

    private func loadTrackData() {
        do {
            let gpxData = try Data(contentsOf: trackURL)
            let gpxString = String(data: gpxData, encoding: .utf8) ?? ""
            locations = GPXParser.parseGPX(gpxString)
            locationManager.locations = locations

            // Calculate stats from the parsed locations using locationManager
            maxSpeed = locationManager.maxSpeed
            totalDescent = locationManager.calculateVerticalLoss(isMetric: false)
            maxElevation = locationManager.calculateMaxAltitude(isMetric: false)
            totalDescentDistance = locationManager.calculateDownhillDistance(isMetric: false)

            // Extract date from the first location if available
            if let firstLocation = locations.first {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                trackDate = dateFormatter.string(from: firstLocation.timestamp)
            }
        } catch {
            print("Error loading track data:", error.localizedDescription)
        }
    }
    
    private func createPolyline(from locations: [CLLocation]) -> MKPolyline {
        let coordinates = locations.map { $0.coordinate }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    private func mapType(from mapStyle: MapStyle) -> MKMapType {
        switch mapStyle {
        case .normal:
            return .standard
        case .satellite:
            return .satellite
        case .hybrid:
            return .hybrid
        }
    }
}

struct MapStyleButton: View {
    let style: MapStyle
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(style.rawValue)
                .padding()
                .background(isSelected ? Color.blue : Color.white)
                .foregroundColor(isSelected ? .white : .blue)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
                )
        }
        .padding(.horizontal, 8)
    }
}

struct TrackMapStats: View {
    var selectedMapStyle: MapStyle
    var maxSpeed: Double
    var totalDescent: Double
    var maxElevation: Double
    var totalDescentDistance: Double
    var trackDate: String
    var username: String

    var body: some View {
        let textColor = selectedMapStyle != .normal ? Color.white : Color.black
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Untracked")
                        .font(Font.custom("Good Times", size: 20))
                        .foregroundColor(textColor)
                    Text(username)
                        .foregroundColor(textColor)
                    Text(trackDate)
                        .foregroundColor(textColor)
                }
                
                Spacer()
            }
            .padding(.horizontal, 30) // Ensure there's padding to prevent text touching the edges

            Spacer()
            
            HStack {
                VStack(alignment: .leading){
                    HStack {
                        Image(systemName: "gauge.with.dots.needle.100percent")
                            .font(.title)
                            .foregroundColor(textColor)
                        Text("\(String(format: "%.1f", maxSpeed)) mph")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    HStack {
                        Image(systemName: "arrow.down")
                            .font(.title)
                            .foregroundColor(textColor)
                        Text("\(String(format: "%.1f", totalDescent)) ft")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                }
                Spacer()
                
                VStack(alignment: .leading){
                    HStack {
                        Image(systemName: "arrow.up.to.line")
                            .font(.title)
                            .foregroundColor(textColor)
                        Text("\(String(format: "%.1f", maxElevation)) ft")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    HStack {
                        Image(systemName: "arrow.down.right")
                            .font(.title)
                            .foregroundColor(textColor)
                        Text("\(String(format: "%.1f", totalDescentDistance)) mi")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                }
            }
            .padding(.horizontal, 30) // Same padding here for consistency
        }
        .frame(maxWidth: .infinity) // Ensure this VStack takes up as much width as available within its parent
    }
}
