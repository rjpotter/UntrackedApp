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
    @Binding var isMetric: Bool
    
    // Refactored Statistics data
    private var statistics: [Statistic] {
        isMetric ? metricsStatistics : imperialStatistics
    }
    
    private var metricsStatistics: [Statistic] {
        let speedInKmh = locationManager.maxSpeed * 3.6 // Convert m/s to km/h
        let distanceInKilometers = locationManager.totalDistance / 1000 // Convert to km
        let verticalInMeters = locationManager.totalVertical
        let altitudeInMeters = locationManager.currentAltitude
        
        return [
            Statistic(title: "Max Speed", value: "\(speedInKmh.rounded(toPlaces: 1)) km/h"),
            Statistic(title: "Distance", value: "\(distanceInKilometers.rounded(toPlaces: 1)) km"),
            Statistic(title: "Vertical", value: "\(verticalInMeters.rounded(toPlaces: 1)) m"),
            Statistic(title: "Altitude", value: "\(altitudeInMeters.rounded(toPlaces: 1)) m"),
            Statistic(title: "Duration", value: formatDuration(elapsedTime))
        ]
    }
    
    private var imperialStatistics: [Statistic] {
        let speedInMph = locationManager.maxSpeed * 2.23694 // Convert m/s to mph
        let distanceInMiles = locationManager.totalDistance * 0.000621371 // Convert meters to miles
        let verticalInFeet = locationManager.totalVertical * 3.28084 // Convert meters to feet
        let altitudeInFeet = locationManager.currentAltitude * 3.28084 // Convert meters to feet
        
        return [
            Statistic(title: "Max Speed", value: "\(speedInMph.rounded(toPlaces: 1)) mph"),
            Statistic(title: "Distance", value: "\(distanceInMiles.rounded(toPlaces: 1)) mi"),
            Statistic(title: "Total Vertical", value: "\(verticalInFeet.rounded(toPlaces: 1)) ft"),
            Statistic(title: "Altitude", value: "\(altitudeInFeet.rounded(toPlaces: 1)) ft"),
            Statistic(title: "Duration", value: formatDuration(elapsedTime))
        ]
    }
    
    // Calculate rows
    private var rows: [[Statistic]] {
        var rows: [[Statistic]] = []
        var currentRow: [Statistic] = []

        for statistic in statistics {
            if currentRow.isEmpty {
                currentRow.append(statistic)
            } else {
                rows.append(currentRow + [statistic])
                currentRow = []
            }
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    var body: some View {
        VStack {
            // Header
            Text("SnowCountry")
                .font(Font.custom("Good Times", size: 30))
                .padding(.top)
            ZStack {
                TrackViewMap(trackViewMap: $trackViewMap, locations: locationManager.locations)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .shadow(radius: 5)

                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        if !showConfirmation && !showSave {
                            Button(action: {
                                if tracking {
                                    withAnimation(Animation.linear(duration: 0.5)){
                                        showConfirmation = true
                                        locationManager.stopTracking()
                                        stopTimer()
                                    }
                                } else {
                                    locationManager.resetTrackingData() // Reset tracking data
                                    trackViewMap.removeOverlays(trackViewMap.overlays) // Clear map overlays
                                    resetTimer()
                                    locationManager.startTracking()
                                    tracking = true
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Image(systemName: tracking ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 75))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .orange)
                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                    }
                    

                    if showConfirmation {
                        ConfirmationOverlay()
                    }

                    if showSave {
                        SaveOverlay()
                    }
                }
            }
            Spacer()
            
            // Statistics Grid
            statisticsGrid
            
            Spacer()
        }
        .background(Color("Background").opacity(0.5))
        
    }
    
    // Statistics Grid
    var statisticsGrid: some View {
        ForEach(rows, id: \.self) { row in
            LazyVGrid(columns: row.count == 1 ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(row, id: \.self) { stat in
                    if stat.title == "Total Vertical" {
                        StatisticCard(
                            statistic: stat,
                            icon: "arrow.down",
                            iconColor: .red
                        )
                        .frame(maxWidth: row.count == 1 ? .infinity : nil)
                    } else {
                        StatisticCard(statistic: stat)
                        .frame(maxWidth: row.count == 1 ? .infinity : nil)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    private func resetTimer() {
        elapsedTime = 0
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
        VStack {
            VStack {
                HStack(spacing: 20) {
                    Button(action: resumeTracking) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 75))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .orange)
                    }

                    Button(action: finishTracking) {
                        Image(systemName: "flag.checkered.circle.fill")
                            .font(.system(size: 75))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .orange)
                    }
                }
            }
            
        }
    }
    
    private func resumeTracking() {
        locationManager.startTracking()
        startTimer()
        tracking = true
        withAnimation {
            showSave = false
            showConfirmation = false
        }
    }
    
    private func finishTracking() {
        locationManager.stopTracking()
        tracking = false
        withAnimation {
            showSave = true
            showConfirmation = false
        }
    }

    private func SaveOverlay() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("Name Your Track")
                    .font(.title2)
                    .foregroundColor(.primary)

                TextField("Enter Track Name", text: $trackName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack(spacing: 20) {
                    Button("Save") {
                        locationManager.saveLocationsToFile(trackName: trackName)
                        showSave = false
                        elapsedTime = 0
                        trackName = ""
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Delete") {
                        locationManager.resetTrackingData()
                        showSave = false
                        elapsedTime = 0
                        trackName = ""
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding()
            Spacer()
        }
    }

    // Custom Button Styles
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(Color.gray.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


