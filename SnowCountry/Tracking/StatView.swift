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

    var body: some View {
        VStack {
            if let trackData = trackData {
                // Display track statistics with default values for missing data
                Text("Max Speed: \(trackData.maxSpeed ?? 0) m/s")
                Text("Total Distance: \(trackData.totalDistance ?? 0) meters")
                Text("Total Elevation Gain: \(trackData.totalElevationGain ?? 0) meters")
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
