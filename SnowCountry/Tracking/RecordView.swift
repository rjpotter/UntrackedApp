//
//  RecordView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.

import SwiftUI
import MapKit

// Custom struct for statistics
struct Statistic: Hashable {
    let title: String
    let value: String
}

struct RecordView: View {
    @State private var tracking = false
    @ObservedObject var locationManager = LocationManager()
    @State private var trackViewMap = MKMapView()

    // Statistics data
    private var statistics: [Statistic] {
        return [
            Statistic(title: "Max Speed", value: "\(locationManager.maxSpeed) m/s"),
            Statistic(title: "Total Distance", value: "\(locationManager.totalDistance) m"),
            Statistic(title: "Total Elevation Gain", value: "\(locationManager.totalElevationGain) m"),
            Statistic(title: "Current Altitude", value: "\(locationManager.currentAltitude) m"),
            Statistic(title: "Duration", value: formatDuration(locationManager.recordingDuration))
        ]
    }

    // Calculate rows for grid
    private var rows: [[Statistic]] {
        var rows: [[Statistic]] = []
        var currentRow: [Statistic] = []

        for statistic in statistics {
            currentRow.append(statistic)
            if currentRow.count == 2 || statistic == statistics.last! {
                rows.append(currentRow)
                currentRow = []
            }
        }

        return rows
    }

    var body: some View {
        VStack {
            ForEach(rows, id: \.self) { row in
               HStack {
                   ForEach(row, id: \.self) { item in
                       StatisticsBox(statistic: item)
                           .frame(maxWidth: .infinity)
                   }
               }
           }

            Spacer()
            
            ZStack {
                TrackViewMap(trackViewMap: $trackViewMap, locations: locationManager.locations)
                    .frame(height: 400) // Set a fixed height for the map view
                    .listRowInsets(EdgeInsets()) // Make the map view full-width
                
                VStack {
                    Spacer()
                    
                    // Start/Stop Recording Button
                    Button(action: {
                        self.tracking.toggle()
                        if self.tracking {
                            self.locationManager.startTracking()
                        } else {
                            self.locationManager.stopTracking()
                        }
                    }) {
                        Text(tracking ? "Stop Recording" : "Start Recording")
                    }
                    .padding()
                    .background(tracking ? (Color.red) : (Color.blue))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                }
            }
        }
        .padding()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
}

struct StatisticsBox: View {
    var statistic: Statistic

    var body: some View {
        VStack {
            Text(statistic.title)
                .font(.headline)
            Spacer()
            Text(statistic.value)
                .font(.body)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
