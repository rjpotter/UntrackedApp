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
    var trackFileName: String
    @State private var trackData: TrackData?
    @State private var locations: [CLLocation] = []
    @State private var trackHistoryViewMap = MKMapView()

    var body: some View {
        VStack {
            if let trackData = trackData {
                // Display track statistics
                Text("Max Speed: \(trackData.maxSpeed) m/s")
                Text("Total Distance: \(trackData.totalDistance) meters")
                Text("Total Elevation Gain: \(trackData.totalElevationGain) meters")
                Text("Recording Duration: \(formatDuration(trackData.recordingDuration))")

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
        let fileURL = LocationManager().getDocumentsDirectory().appendingPathComponent(trackFileName)
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            trackData = try decoder.decode(TrackData.self, from: data)
            locations = trackData?.locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) } ?? []
            print("Loaded track data successfully")
        } catch {
            print("Loading data from: \(fileURL)")
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
}

