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
    var user: User
    @ObservedObject var socialViewModel: SocialViewModel
    @State private var trackDate: String = ""
    @State private var selectedMapStyle: MapStyle = .normal
    @State private var locations: [CLLocation] = []
    @State private var maxSpeed: Double = 0.0
    @State private var totalDescent: Double = 0.0
    @State private var maxElevation: Double = 0.0
    @State private var totalDescentDistance: Double = 0.0
    @StateObject private var locationManager = LocationManager()
    @State private var navigateToSelectPhotoView = false
    @State private var generatedMapImage: UIImage?
    @Binding var navigateBackToRoot: Bool // Add this binding
    private let mapView = MKMapView()

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(trackName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(trackDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 0)

            ZStack {
                TrackImageMapView(locations: locations, selectedMapStyle: $selectedMapStyle)
                    .frame(height: 330)
                    .cornerRadius(15)
                    .padding()
                    .shadow(radius: 5)

                TrackMapStats(
                    selectedMapStyle: selectedMapStyle,
                    maxSpeed: maxSpeed,
                    totalDescent: totalDescent,
                    maxElevation: maxElevation,
                    totalDescentDistance: totalDescentDistance,
                    trackDate: trackDate,
                    username: user.username
                )
                .padding(.top, 10)
                .frame(height: 290)
            }
            .frame(maxWidth: .infinity)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MapStyle.allCases, id: \.self) { style in
                        MapStyleButton(style: style, isSelected: selectedMapStyle == style) {
                            selectedMapStyle = style
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .padding(.bottom, 20)
        .navigationTitle("Track Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
                    ) { image in
                        self.generatedMapImage = image
                        self.navigateToSelectPhotoView = true
                    }
                }) {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
            }
        }
        .onAppear {
            loadTrackData()
        }
        .background(
            NavigationLink(
                destination: SelectPhotoView(socialViewModel: socialViewModel, mapImage: generatedMapImage ?? UIImage(systemName: "photo")!, navigateBackToRoot: $navigateBackToRoot),
                isActive: $navigateToSelectPhotoView,
                label: {
                    EmptyView()
                }
            )
        )
    }

    private func loadTrackData() {
        do {
            let gpxData = try Data(contentsOf: trackURL)
            let gpxString = String(data: gpxData, encoding: .utf8) ?? ""
            locations = GPXParser.parseGPX(gpxString)
            locationManager.locations = locations

            maxSpeed = locationManager.maxSpeed
            totalDescent = locationManager.calculateVerticalLoss(isMetric: false)
            maxElevation = locationManager.calculateMaxAltitude(isMetric: false)
            totalDescentDistance = locationManager.calculateDownhillDistance(isMetric: false)

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
                .shadow(radius: isSelected ? 5 : 0)
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
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Untracked")
                        .font(Font.custom("Good Times", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(username)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(trackDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)

            Spacer()
            
            HStack {
                VStack(alignment: .leading){
                    HStack {
                        Image(systemName: "gauge.with.dots.needle.100percent")
                            .font(.title)
                        Text("\(String(format: "%.1f", maxSpeed)) mph")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    HStack {
                        Image(systemName: "arrow.down")
                            .font(.title)
                        Text("\(String(format: "%.1f", totalDescent)) ft")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                
                VStack(alignment: .leading){
                    HStack {
                        Image(systemName: "arrow.up.to.line")
                            .font(.title)
                        Text("\(String(format: "%.1f", maxElevation)) ft")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    HStack {
                        Image(systemName: "arrow.down.right")
                            .font(.title)
                        Text("\(String(format: "%.1f", totalDescentDistance)) mi")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
    }
}
