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
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showConfirmation = false
    @State private var meters = true
    @State private var showSave = false
    @State var trackName: String = ""
    
    // Refactored Statistics data
    private var statistics: [Statistic] {
        if meters {
            return metricsStatistics
        } else {
            return imperialStatistics
        }
    }
    
    private var metricsStatistics: [Statistic] {
        let speedInKmh = locationManager.currentSpeed * 3.6 // Convert m/s to km/h
        let distanceInKilometers = locationManager.totalDistance / 1000 // Convert to km
        let elevationGainInMeters = locationManager.totalElevationGain
        let altitudeInMeters = locationManager.currentAltitude
        
        return [
            Statistic(title: "Max Speed", value: "\(speedInKmh.rounded(toPlaces: 1)) km/h"),
            Statistic(title: "Total Distance", value: "\(distanceInKilometers.rounded(toPlaces: 1)) km"),
            Statistic(title: "Total Elevation Gain", value: "\(elevationGainInMeters.rounded(toPlaces: 1)) m"),
            Statistic(title: "Current Altitude", value: "\(altitudeInMeters.rounded(toPlaces: 1)) m"),
            Statistic(title: "Recording Time", value: formatDuration(elapsedTime))
        ]
    }
    
    private var imperialStatistics: [Statistic] {
        let speedInMph = locationManager.currentSpeed * 2.23694 // Convert m/s to mph
        let distanceInMiles = locationManager.totalDistance * 0.000621371 // Convert meters to miles
        let elevationGainInFeet = locationManager.totalElevationGain * 3.28084 // Convert meters to feet
        let altitudeInFeet = locationManager.currentAltitude * 3.28084 // Convert meters to feet
        
        return [
            Statistic(title: "Max Speed", value: "\(speedInMph.rounded(toPlaces: 1)) mph"),
            Statistic(title: "Total Distance", value: "\(distanceInMiles.rounded(toPlaces: 1)) mi"),
            Statistic(title: "Total Elevation Gain", value: "\(elevationGainInFeet.rounded(toPlaces: 1)) ft"),
            Statistic(title: "Current Altitude", value: "\(altitudeInFeet.rounded(toPlaces: 1)) ft"),
            Statistic(title: "Recording Time", value: formatDuration(elapsedTime))
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
                    
                    HStack {
                        if !showConfirmation && !showSave {
                            Button(action: {
                                self.meters.toggle()
                            }) {
                                Text(meters ? "ft" : "m")
                            }
                            .padding()
                            .background(meters ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.trailing, 20)
                            
                            // Start/Stop Recording Button
                            Button(action: {
                                if tracking {
                                    showConfirmation = true
                                } else {
                                    startTimer()
                                    locationManager.startTracking()
                                    tracking = true
                                }
                            }) {
                                Text(tracking ? "Stop Recording" : "Start Recording")
                            }
                            .padding()
                            .background(tracking ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 70)

                    if showConfirmation {
                        // Confirmation Overlay
                        ConfirmationOverlay()
                    }
                    
                    if showSave {
                        SaveOverlay()
                    }
                }
            }
        }
        .padding()
    }
    
    private func startTimer() {
        elapsedTime = 0 // Reset the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
    
    private func ConfirmationOverlay() -> some View {
        // Full-screen overlay with centered content
        VStack {
            VStack {
                Text("Are you sure you want to stop recording?")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                
                HStack(spacing: 20) {
                    Button("Confirm") {
                        stopTimer()
                        locationManager.stopTracking()
                        tracking = false
                        showSave = true
                        showConfirmation = false
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        showConfirmation = false
                        tracking = true
                        showSave = false
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.8))
            .cornerRadius(20)
            
            Spacer()
        }
    }
    
    private func SaveOverlay() -> some View {
        VStack {
            Text("Name Your Track")
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            TextField("Enter Track Name", text: $trackName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack(spacing: 20) {
                Button("Save") {
                    locationManager.saveLocationsToFile()
                    showSave = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Cancel") {
                    showSave = false
                }
                .padding()
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.8))
        .cornerRadius(20)
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

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
