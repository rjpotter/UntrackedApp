//
//  TrackToImageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 3/6/24.
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
    var trackDate: String
    @State private var selectedMapStyle: MapStyle = .normal
    @State private var locations: [CLLocation] = []

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
                
                TrackMapStats(selectedMapStyle: selectedMapStyle)
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

            Spacer()
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
        } catch {
            print("Error loading track data:", error.localizedDescription)
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

    var body: some View {
        let textColor = selectedMapStyle != .normal ? Color.white : Color.black
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Untracked")
                        .font(Font.custom("Good Times", size: 20))
                        .foregroundColor(textColor)
                    Text("RPotts115")
                        .foregroundColor(textColor)
                    Text("3/14/2024")
                        .foregroundColor(textColor)
                    Text("2hr 59min 6 sec")
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
                        Text("42 mph")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    HStack {
                        Image(systemName: "arrow.down")
                            .font(.title)
                            .foregroundColor(textColor)
                        Text("10,597.5 ft")
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
                        Text("3,899.0 ft")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    HStack {
                        Image(systemName: "arrow.down.right")
                            .font(.title)
                            .foregroundColor(textColor)
                        Text("8.2 mi")
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


