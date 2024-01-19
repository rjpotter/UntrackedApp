//
//  RecordView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.

import SwiftUI
import MapKit

struct Statistic: Hashable {
    let title: String
    let value: String
    let image1: String? // Store the name of the image
    let value1: String?
    let image2: String? // Store the name of the image
    let value2: String?
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
        let averageSpeedKmh = locationManager.avgSpeed * 3.6
        let distanceInKilometers = locationManager.totalDistance / 1000 // Convert to km
        let upDistanceKm = locationManager.totalUpDistance / 1000
        let downDistanceKm = locationManager.totalDownDistance / 1000
        let verticalInMeters = locationManager.totalDownVertical
        let upVerticalM = locationManager.totalUpVertical
        let deltaVerticalM = locationManager.deltaVertical
        let altitudeInMeters = locationManager.currentAltitude
        let peakAltitudeM = locationManager.peakAltitude
        let lowAltitudeM = locationManager.lowAltitude
        
        return [
            Statistic(
                title: "Max Speed",
                value: numberFormatter(speedInKmh, isMetric: true, unit: "kmh"),
                image1: "gauge.with.dots.needle.50percent",
                value1: numberFormatter(averageSpeedKmh, isMetric: true, unit: "kmh"),
                image2: nil,
                value2: ""
            ),
            Statistic(
                title: "Distance",
                value: numberFormatter(distanceInKilometers, isMetric: true, unit: "km"),
                image1: "arrow.up.right",
                value1: numberFormatter(upDistanceKm, isMetric: true, unit: "km"),
                image2: "arrow.down.right",
                value2: numberFormatter(downDistanceKm, isMetric: true, unit: "km")
            ),
            Statistic(
                title: "Vertical",
                value: numberFormatter(verticalInMeters, isMetric: true, unit: "m"),
                image1: "arrow.up",
                value1: numberFormatter(upVerticalM, isMetric: true, unit: "m"),
                image2: "arrow.up.and.down",
                value2: numberFormatter(deltaVerticalM, isMetric: true, unit: "m")
            ),
            Statistic(
                title: "Altitude",
                value: numberFormatter(altitudeInMeters, isMetric: true, unit: "m"),
                image1: "arrow.up.to.line",
                value1: numberFormatter(peakAltitudeM, isMetric: true, unit: "m"),
                image2: "arrow.down.to.line",
                value2: numberFormatter(lowAltitudeM, isMetric: true, unit: "m")
            ),
            Statistic(
                title: "Duration",
                value: formatDuration(elapsedTime),
                image1: "arrow.up.right",
                value1: "",
                image2: "arrow.down.right",
                value2: ""
            )
        ]
    }
    
    private var imperialStatistics: [Statistic] {
        let speedInMph = locationManager.maxSpeed * 2.23694 // Convert m/s to mph
        let averageSpeedMph = locationManager.avgSpeed * 2.23694
        let distanceInMiles = locationManager.totalDistance * 0.000621371 // Convert meters to miles
        let downDistanceMi = locationManager.totalDownDistance * 0.000621371
        let upDistanceMi = locationManager.totalUpDistance * 0.000621371
        let verticalInFeet = locationManager.totalDownVertical * 3.28084 // Convert meters to feet
        let upVerticalFt = locationManager.totalUpVertical * 3.28084
        let deltaVerticalFt = locationManager.deltaVertical * 3.28084
        let altitudeInFeet = locationManager.currentAltitude * 3.28084
        let peakAltitudeFt = locationManager.peakAltitude * 3.28084
        let lowAltitudeFt = locationManager.lowAltitude * 3.28084
        
        return [
            Statistic(
                title: "Max Speed",
                value: numberFormatter(speedInMph, isMetric: false, unit: "mph"),
                image1: "gauge.with.dots.needle.50percent",
                value1: numberFormatter(averageSpeedMph, isMetric: false, unit: "mph"),
                image2: nil,
                value2: ""
            ),
            Statistic(
                title: "Distance",
                value: numberFormatter(distanceInMiles, isMetric: false, unit: "mi"),
                image1: "arrow.up.right",
                value1: numberFormatter(upDistanceMi, isMetric: false, unit: "mi"),
                image2: "arrow.down.right",
                value2: numberFormatter(downDistanceMi, isMetric: false, unit: "mi")
            ),
            Statistic(
                title: "Vertical",
                value: numberFormatter(verticalInFeet, isMetric: false, unit: "ft"),
                image1: "arrow.up",
                value1: numberFormatter(upVerticalFt, isMetric: false, unit: "ft"),
                image2: "arrow.up.and.down",
                value2: numberFormatter(deltaVerticalFt, isMetric: false, unit: "ft")
            ),
            Statistic(
                title: "Altitude",
                value: numberFormatter(altitudeInFeet, isMetric: false, unit: "ft"),
                image1: "arrow.up.to.line",
                value1: numberFormatter(peakAltitudeFt, isMetric: false, unit: "ft"),
                image2: "arrow.down.to.line",
                value2: numberFormatter(lowAltitudeFt, isMetric: false, unit: "ft")
            ),
            Statistic(
                title: "Duration",
                value: formatDuration(elapsedTime),
                image1: "arrow.up.right",
                value1: "",
                image2: "arrow.down.right",
                value2: ""
            )
        ]
    }

    func numberFormatter(_ value: Double, isMetric: Bool, unit: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1

        if isMetric {
            formatter.groupingSeparator = "."
            formatter.decimalSeparator = ","
        } else {
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
        }

        let number = NSNumber(value: value)
        let formattedValue = formatter.string(from: number) ?? "\(value)"
        return "\(formattedValue) \(unit)"
    }
    
    // Calculate rows
    private var rows: [[Statistic]] {
        var rows: [[Statistic]] = []
        var currentRow: [Statistic] = []

        for statistic in statistics {
            if currentRow.isEmpty {
                // Start a new row with the current statistic
                currentRow.append(statistic)
            } else {
                // If the current row has a statistic and the current statistic is "Duration",
                // place it in the same row as "Max Speed". Otherwise, start a new row.
                if currentRow.first?.title == "Max Speed" && statistic.title == "Duration" {
                    currentRow.append(statistic)
                    rows.append(currentRow)
                    currentRow = []
                } else {
                    // Finish the current row and start a new one
                    rows.append(currentRow)
                    currentRow = [statistic]
                }
            }
        }

        // Add the last row if it's not empty
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
                    if stat.title == "Vertical" {
                        StatisticCard(
                            icon: "arrow.down",
                            statistic: stat,
                            iconColor: .red
                        )
                        .frame(maxWidth: row.count == 1 ? .infinity : nil)
                    } else if stat.title == "Up" {
                        StatisticCard(
                            icon: "arrow.up",
                            statistic: stat,
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


