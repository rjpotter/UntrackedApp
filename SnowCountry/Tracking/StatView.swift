//
//  StatView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/2/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct StatView: View {
    var trackFilePath: URL
    @State private var trackData: TrackData?
    @State private var locations: [CLLocation] = []
    @State private var trackHistoryViewMap = MKMapView()
    @Binding var isMetric: Bool

    var body: some View {
        VStack {
            if let trackData = trackData {
                // Convert values based on unit preference
                let speed = (isMetric ? (trackData.maxSpeed ?? 0) : (trackData.maxSpeed ?? 0) * 2.23694).rounded(toPlaces: 1)
                let distance = (isMetric ? (trackData.totalDistance ?? 0) / 1000 : (trackData.totalDistance ?? 0) * 0.000621371).rounded(toPlaces: 1)
                let vertical = (isMetric ? (trackData.totalElevationGain ?? 0) : (trackData.totalElevationGain ?? 0) * 3.28084).rounded(toPlaces: 1)
                // Display track statistics with formatted values
                Text("Max Speed: \(String(format: "%.1f", speed)) \(isMetric ? "km/h" : "mph")")
                Text("Total Distance: \(String(format: "%.1f", distance)) \(isMetric ? "km" : "mi")")
                Text("Vertical: \(String(format: "%.1f", vertical)) \(isMetric ? "meters" : "feet")")
                Text("Recording Duration: \(formatDuration(trackData.recordingDuration ?? 0))")


                // Map view displaying the track
                TrackHistoryViewMap(trackHistoryViewMap: $trackHistoryViewMap, locations: locations)
                    .frame(height: 400) // Adjust height as needed
            } else {
                Text("Loading track data...")
            }
        }
        .onAppear(perform: loadTrackData)
    }

    private func loadTrackData() {
        print("Loading track data from URL: \(trackFilePath)")
        do {
            let data = try Data(contentsOf: trackFilePath)
            let decodedData = try JSONDecoder().decode(TrackData.self, from: data)
            trackData = decodedData
            print("Track data loaded: \(decodedData)")

            // Convert CodableLocation to CLLocation for map view
            locations = decodedData.locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        } catch {
            print("Error loading track data: \(error)")
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
}
