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
            Statistic(title: "Total Distance", value: "\(distanceInKilometers.rounded(toPlaces: 1)) km"),
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
            Statistic(title: "Total Distance", value: "\(distanceInMiles.rounded(toPlaces: 1)) mi"),
            Statistic(title: "Vertical", value: "\(verticalInFeet.rounded(toPlaces: 1)) ft"),
            Statistic(title: "Altitude", value: "\(altitudeInFeet.rounded(toPlaces: 1)) ft"),
            Statistic(title: "Duration", value: formatDuration(elapsedTime))
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
            Text("SnowCountry")
                .font(Font.custom("Good Times", size:30))
            ZStack {
                TrackViewMap(trackViewMap: $trackViewMap, locations: locationManager.locations)
                    .frame(height: 450)
                    .listRowInsets(EdgeInsets())

                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        if !showConfirmation && !showSave {
                            Button(action: {
                                if tracking {
                                    withAnimation(Animation.linear(duration: 0.5)){
                                        showConfirmation = true
                                    }
                                } else {
                                    startTimer()
                                    locationManager.startTracking()
                                    tracking = true
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    if tracking {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.system(size: 60))
                                    } else {
                                        Text("START") // "Start" text when not tracking
                                            .font(.system(size: 20))
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                }
                            }
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Color.orange) // Set both to orange
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                            .shadow(color: Color("base").opacity(0.9), radius: 5, x: 0, y: 2)
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
            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { item in
                        StatisticsBox(statistic: item)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .background(Color("Background").opacity(0.5))
        
    }

    private func startTimer() {
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
                    Button("RESUME") {
                        withAnimation {
                            showConfirmation = false
                            tracking = true
                            showSave = false
                        }
                    }
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .frame(width: 100, height: 100)
                    .foregroundColor( Color.orange )
                    .background( Color.white )
                    .cornerRadius(50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.orange, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)

                    Button("FINISH") {
                        stopTimer()
                        locationManager.stopTracking()
                        tracking = false
                        withAnimation {
                            showSave = true
                            showConfirmation = false
                        }
                    }
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .frame(width: 100, height: 100)
                    .foregroundColor( Color.white )
                    .background( Color.orange )
                    .cornerRadius(50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.white, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
            
        }
    }

    private func SaveOverlay() -> some View {
        VStack {
            Spacer()
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
                        locationManager.saveLocationsToFile(trackName: trackName)
                        showSave = false
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Delete") {
                        locationManager.saveLocationsToFile()
                        showSave = false
                    }
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Spacer()
            }
            
            .background(Color("Background").opacity(0.5))
           
            .padding(.top, 20)
            .padding(.bottom, 25)
            Spacer()
            
        }
    }
}

struct StatisticsBox: View {
    var statistic: Statistic

    var body: some View {
        VStack {
            HStack {
                
                Text(statistic.title)
                    .font(.headline)
               
            }
            
            Text(statistic.value)
                .font(.system(size:25))
                .fontWeight(.semibold)
        }
        .padding(5)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color("Base"))
        
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1))

    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
