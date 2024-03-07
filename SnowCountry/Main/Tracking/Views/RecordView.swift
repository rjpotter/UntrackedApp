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
    
    private var statistics: [Statistic] {
        // Distance
        let distance = locationManager.totalDistance * (isMetric ? 0.001 : 0.000621371)
        let upDistance = locationManager.calculateUphillDistance(isMetric: isMetric)
        let downDistance = locationManager.calculateDownhillDistance(isMetric: isMetric)
        
        // Elevation
        let altitude = locationManager.currentAltitude * (isMetric ? 1.0 : 3.28084)
        let peakAltitude = locationManager.calculateMaxAltitude(isMetric: isMetric)
        let lowAltitude = locationManager.calculateMinAltitude(isMetric: isMetric)
        
        // Vertical
        let vertical = locationManager.calculateVerticalLoss(isMetric: isMetric)
        let upVertical = locationManager.calculateVerticalGain(isMetric: isMetric)
        let deltaVertical = locationManager.calculateVerticalChange(isMetric: isMetric)
        
        // Speed
        let speed = locationManager.maxSpeed * (isMetric ? 3.6 : 2.23694)
        let averageDownSpeed = locationManager.calculateAverageDownhillSpeed(isMetric: isMetric)
        let averageUpSpeed = locationManager.calculateAverageUphillSpeed(isMetric: isMetric)
        
        // Duration
        let duration = formatDuration(elapsedTime)
        let upDuration = formatDuration(calculateTimeSpentUphill(locations: locationManager.locations))
        let downDuration = formatDuration(calculateTimeSpentDownhill(locations: locationManager.locations))

        return [
            Statistic(
                title: "Max Speed",
                value: numberFormatter(speed, isMetric: isMetric, unit: isMetric ? "km/h" : "mph"),
                image1: "arrow.up.right",
                value1: numberFormatter(averageUpSpeed, isMetric: isMetric, unit: isMetric ? "km/h" : "mph"),
                image2: "arrow.down.right",
                value2: numberFormatter(averageDownSpeed, isMetric: isMetric, unit: isMetric ? "km/h" : "mph")
            ),
            Statistic(
                title: "Distance",
                value: numberFormatter(distance, isMetric: isMetric, unit: isMetric ? "km" : "mi"),
                image1: "arrow.up.right",
                value1: numberFormatter(upDistance, isMetric: isMetric, unit: isMetric ? "km" : "mi"),
                image2: "arrow.down.right",
                value2: numberFormatter(downDistance, isMetric: isMetric, unit: isMetric ? "km" : "mi")
            ),
            Statistic(
                title: "Vertical",
                value: numberFormatter(vertical, isMetric: isMetric, unit: isMetric ? "m" : "ft"),
                image1: "arrow.up",
                value1: numberFormatter(upVertical, isMetric: isMetric, unit: isMetric ? "m" : "ft"),
                image2: "arrow.up.and.down",
                value2: numberFormatter(deltaVertical, isMetric: isMetric, unit: isMetric ? "m" : "ft")
            ),
            Statistic(
                title: "Altitude",
                value: numberFormatter(altitude, isMetric: isMetric, unit: isMetric ? "m" : "ft"),
                image1: "arrow.up.to.line",
                value1: numberFormatter(peakAltitude, isMetric: isMetric, unit: isMetric ? "m" : "ft"),
                image2: "arrow.down.to.line",
                value2: numberFormatter(lowAltitude, isMetric: isMetric, unit: isMetric ? "m" : "ft")
            ),
            Statistic(
                title: "Duration",
                value: duration,
                image1: "arrow.up.right",
                value1: upDuration,
                image2: "arrow.down.right",
                value2: downDuration
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
            Text("Untracked")
                .font(Font.custom("Good Times", size: 30))
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


