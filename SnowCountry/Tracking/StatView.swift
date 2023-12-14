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
    @State private var fileToShare: ShareableFile?
    @State private var isLoading = false
   @State private var loadingError: String?

    var body: some View {
        ScrollView {
            VStack {
                if let trackData = trackData {
                    // Extract track name or use date from file name
                    let trackName = trackData.trackName ?? defaultTrackName(from: trackFilePath)
                    Text(trackName)
                        .font(.largeTitle)
                        .padding(.top)
                    
                    // Map view displaying the track
                    TrackHistoryViewMap(trackHistoryViewMap: $trackHistoryViewMap, locations: locations)
                        .frame(height: 300) // Adjust height as needed
                        .cornerRadius(15)
                        .padding()
                    
                    // Statistics in a grid
                    let statistics = createStatistics(isMetric: isMetric, trackData: trackData)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(statistics, id: \.self) { stat in
                            StatisticCard(statistic: stat)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: loadTrackData)
    }

    private func loadTrackData() {
        isLoading = true
        loadingError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: trackFilePath)
                let decodedData = try JSONDecoder().decode(TrackData.self, from: data)
                DispatchQueue.main.async {
                    self.trackData = decodedData
                    self.locations = decodedData.locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingError = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func resetAndLoadNewTrack() {
        trackData = nil
        locations = []
        loadTrackData()
    }
    
    private func defaultTrackName(from filePath: URL) -> String {
        // Extract the date from the file name
        let fileName = filePath.deletingPathExtension().lastPathComponent
        // Assuming the date format in the file name is like "MM-dd-yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        if let date = dateFormatter.date(from: fileName) {
            dateFormatter.dateStyle = .long
            return dateFormatter.string(from: date)
        } else {
            return fileName
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
    
    // Additional function to create statistics
    private func createStatistics(isMetric: Bool, trackData: TrackData) -> [Statistic] {
        // Convert values based on unit preference
        let speed = (isMetric ? (trackData.maxSpeed ?? 0) : (trackData.maxSpeed ?? 0) * 2.23694).rounded(toPlaces: 1)
        let distance = (isMetric ? (trackData.totalDistance ?? 0) / 1000 : (trackData.totalDistance ?? 0) * 0.000621371).rounded(toPlaces: 1)
        let vertical = (isMetric ? (trackData.totalVertical ?? 0) : (trackData.totalVertical ?? 0) * 3.28084).rounded(toPlaces: 1)

        // Create an array of Statistic structs
        return [
            Statistic(title: "Max Speed", value: "\(speed) \(isMetric ? "km/h" : "mph")"),
            Statistic(title: "Total Distance", value: "\(distance) \(isMetric ? "km" : "mi")"),
            Statistic(title: "Vertical", value: "\(vertical) \(isMetric ? "meters" : "feet")"),
            Statistic(title: "Duration", value: formatDuration(trackData.recordingDuration ?? 0))
        ]
    }
}

// Struct for StatisticCard
struct StatisticCard: View {
    let statistic: Statistic

    var body: some View {
        VStack {
            Text(statistic.title)
                .font(.headline)
            Text(statistic.value)
                .font(.title2)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}
