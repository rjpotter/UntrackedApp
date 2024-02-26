//
//  StatView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/1/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct StatView: View {
    var trackFilePath: URL
    @ObservedObject var locationManager = LocationManager()
    @State private var trackData: TrackData?
    @State private var locations: [CLLocation] = []
    @State private var trackHistoryViewMap = MKMapView()
    @EnvironmentObject var userSettings: UserSettings
    @State private var fileToShare: ShareableFile?
    @State private var isLoading = false
    @State private var loadingError: String?
    @State private var loadedTrackData: TrackData?
    @State private var showingEditTrackSheet = false
    @State private var newTrackName: String = ""
    @State var trackName: String
    var trackDate: String

    var body: some View {
        ScrollView {
            VStack {
                // Extract the file name from trackFilePath
                let fileName = trackFilePath.lastPathComponent
                HStack {
                    Text(trackName)
                        .font(.largeTitle)
                        .padding(.top)
                    
                    Button(action: {
                        self.showingEditTrackSheet = true
                        self.newTrackName = trackName // Initialize with current track name
                    }) {
                        Image(systemName: "pencil")
                            .font(.title)
                            .padding(.top)
                    }
                }
                Text(trackDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TrackHistoryViewMap(trackHistoryViewMap: $trackHistoryViewMap, locations: locations)
                    .frame(height: 300)
                    .cornerRadius(15)
                    .padding()

                if let trackData = trackData {
                    StatisticsGridView(statistics: createStatistics(isMetric: userSettings.isMetric, trackData: trackData))
                } else if !locations.isEmpty {
                    StatisticsGridView(statistics: createGPXStatistics(locations: locations, isMetric: userSettings.isMetric))
                }
            }
        }
        .onAppear(perform: {
            _ = loadTrackData()
        })
        
        .sheet(isPresented: $showingEditTrackSheet) {
            EditTrackNameView(trackName: $trackName, filePath: trackFilePath)
        }
    }

    func loadTrackData() -> TrackData? {
        isLoading = true
        let fileName = trackFilePath.lastPathComponent
        do {
            if fileName.hasSuffix(".json") {
                // Load JSON file
                let jsonData = try Data(contentsOf: trackFilePath)
                trackData = try JSONDecoder().decode(TrackData.self, from: jsonData)
                locations = trackData?.locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) } ?? []
            } else if fileName.hasSuffix(".gpx") {
                // Load GPX file
                let gpxData = try Data(contentsOf: trackFilePath)
                let gpxString = String(data: gpxData, encoding: .utf8) ?? ""
                locations = GPXParser.parseGPX(gpxString)
            }
        } catch {
            loadingError = error.localizedDescription
        }
        isLoading = false
        updateMapViewWithLocations()
        return trackData
    }
    
    private func updateMapViewWithLocations() {
        guard !locations.isEmpty else {
            print("No locations to display on the map")
            return
        }
        
        print("Updating map view with \(locations.count) locations")
        // Clear any existing overlays
        trackHistoryViewMap.removeOverlays(trackHistoryViewMap.overlays)
        
        // Ensure there are locations to work with
        guard !locations.isEmpty else { return }
        
        // Create and add the polyline
        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        trackHistoryViewMap.addOverlay(polyline)
        
        // Optionally, you can adjust the map region to fit the polyline
        let region = MKCoordinateRegion(polyline.boundingMapRect)
        trackHistoryViewMap.setRegion(region, animated: true)
    }
    
    
    private func defaultTrackName(from filePath: URL) -> String {
        let fileName = filePath.deletingPathExtension().lastPathComponent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        if let date = dateFormatter.date(from: fileName) {
            dateFormatter.dateStyle = .long
            return dateFormatter.string(from: date)
        } else {
            return fileName
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: duration) ?? "0s"
    }
    
    private func createStatistics(isMetric: Bool, trackData: TrackData) -> [Statistic] {
        let speed = (isMetric ? (trackData.maxSpeed ?? 0) : (trackData.maxSpeed ?? 0) * 2.23694).rounded(toPlaces: 1)
        let distance = (isMetric ? (trackData.totalDistance ?? 0) / 1000 : (trackData.totalDistance ?? 0) * 0.000621371).rounded(toPlaces: 1)
        let vertical = (isMetric ? (trackData.totalVertical ?? 0) : (trackData.totalVertical ?? 0) * 3.28084).rounded(toPlaces: 1)
        
        return [
            Statistic(
                title: "Max Speed",
                value: "\(speed) \(userSettings.isMetric ? "km/h" : "mph")",
                image1: "speedometer",
                value1: "",
                image2: nil,
                value2: ""
            ),
            Statistic(
                title: "Distance",
                value: "\(distance) \(userSettings.isMetric ? "km" : "mi")",
                image1: "arrow.up.right",
                value1: "",
                image2: nil,
                value2: ""
            ),
            Statistic(
                title: "Vertical",
                value: "\(vertical) \(userSettings.isMetric ? "m" : "ft")",
                image1: "arrow.up.and.down",
                value1: "",
                image2: nil,
                value2: ""
            ),
            Statistic(
                title: "Duration",
                value: formatDuration(trackData.recordingDuration ?? 0),
                image1: "timer",
                value1: "",
                image2: nil,
                value2: ""
            )
        ]
    }
    
    func formatNumber(_ value: Double, isMetric: Bool, unit: String) -> String {
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
    
    func createGPXStatistics(locations: [CLLocation], isMetric: Bool) -> [Statistic] {
    // Create Stats
        // Distance
        let totalDistance = calculateTotalDistance(locations: locations, isMetric: isMetric)
        let totalUpDistance = calculateTotalUpDistance(locations: locations, isMetric: isMetric)
        let totalDownDistance = calculateTotalDownDistance(locations: locations, isMetric: isMetric)
        
        // Elevation
        let maxElevation = calculateMaxElevation(locations: locations, isMetric: isMetric)
        let minElevation = calculateMinElevation(locations: locations, isMetric: isMetric)
        let deltaElevation = maxElevation - minElevation
        
        // Vertical
        let totalVerticalLoss = calculateTotalElevationLoss(locations: locations, isMetric: isMetric)
        let totalVerticalGain = calculateTotalElevationGain(locations: locations, isMetric: isMetric)
        let totalVerticalChange = calculateTotalElevationChange(locations: locations, isMetric: isMetric)
        
        // Speed
        let maxSpeed = calculateMaxSpeed(locations: locations, isMetric: isMetric)
        let avgUpSpeed = calculateUphillAvgSpeed(locations: locations, isMetric: isMetric)
        let avgDownSpeed = calculateDownhillAvgSpeed(locations: locations, isMetric: isMetric)
        
        // Duration
        let duration = calculateDuration(locations: locations)
        let upDuration = calculateTimeSpentUphill(locations: locations)
        let downDuration = calculateTimeSpentDownhill(locations: locations)
        
    // Format the statistics
        // Distance
        let formattedDistance = formatNumber(totalDistance, isMetric: isMetric, unit: isMetric ? "km" : "mi")
        let formattedUpDistance = formatNumber(totalUpDistance, isMetric: isMetric, unit: isMetric ? "km" : "mi")
        let formattedDownDistance = formatNumber(totalDownDistance, isMetric: isMetric, unit: isMetric ? "km" : "mi")

        // Elevation
        let formattedMaxElevation = formatNumber(maxElevation, isMetric: isMetric, unit: isMetric ? "m" : "ft")
        let formattedMinElevation = formatNumber(minElevation, isMetric: isMetric, unit: isMetric ? "m" : "ft")
        let formattedDeltaElevation = formatNumber(deltaElevation, isMetric: isMetric, unit: isMetric ? "m" : "ft")

        // Vertical
        let formattedVerticalLoss = formatNumber(totalVerticalLoss, isMetric: isMetric, unit: isMetric ? "m" : "ft")
        let formattedVerticalGain = formatNumber(totalVerticalGain, isMetric: isMetric, unit: isMetric ? "m" : "ft")
        let formattedVerticalChange = formatNumber(totalVerticalChange, isMetric: isMetric, unit: isMetric ? "m" : "ft")

        // Speed
        let formattedMaxSpeed = formatNumber(maxSpeed, isMetric: isMetric, unit: isMetric ? "km/h" : "mph")
        let formattedUpSpeed = formatNumber(avgUpSpeed, isMetric: isMetric, unit: isMetric ? "km/h" : "mph")
        let formattedDownAvgSpeed = formatNumber(avgDownSpeed, isMetric: isMetric, unit: isMetric ? "km/h" : "mph")
        
        // Time
        let formattedDuration = formatDuration(duration)
        let formattedUpDuration = formatDuration(upDuration)
        let formattedDownDuration = formatDuration(downDuration)
        
    // Create Statistic objects
        let maxSpeedStat = Statistic(
            title: "Max Speed",
            value: formattedMaxSpeed,
            image1: "arrow.up.right",
            value1: formattedUpSpeed,
            image2: "arrow.down.right",
            value2: formattedDownAvgSpeed
        )
        let distanceStat = Statistic(
            title: "Distance",
            value: formattedDownDistance,
            image1: "arrow.up.right",
            value1: formattedUpDistance,
            image2: "arrow.up.and.down",
            value2: formattedDistance
        )
        let verticalStat = Statistic(
            title: "Vertical",
            value: formattedVerticalLoss,
            image1: "arrow.up",
            value1: formattedVerticalGain,
            image2: "arrow.up.and.down",
            value2: formattedVerticalChange
        )
        let elevationStat = Statistic(
            title: "Elevation",
            value: formattedMaxElevation,
            image1: "arrow.down.to.line",
            value1: formattedMinElevation,
            image2: "arrow.up.and.down",
            value2: formattedDeltaElevation
        )
        let durationStat = Statistic(
            title: "Duration",
            value: formattedDuration,
            image1: "arrow.up.right",
            value1: formattedUpDuration,
            image2: "arrow.down.right",
            value2: formattedDownDuration
        )
        
        return [maxSpeedStat, verticalStat, elevationStat, distanceStat, durationStat]
    }
    
    func extractTrackNameFromGPX(_ gpxString: String) -> String? {
        // Simple XML parsing to extract the track name
        // Note: This is a basic implementation. For complex GPX files, consider using an XML parser library.
        if let range = gpxString.range(of: "<name>", options: .caseInsensitive),
           let endRange = gpxString.range(of: "</name>", options: .caseInsensitive, range: range.upperBound..<gpxString.endIndex) {
            return String(gpxString[range.upperBound..<endRange.lowerBound])
        }
        return nil
    }
}

struct StatisticsGridView: View {
    var statistics: [Statistic]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 5) {
            ForEach(statistics, id: \.self) { stat in
                if stat.title == "Vertical" {
                    StatisticCard(
                        icon: "arrow.down",
                        statistic: stat,
                        iconColor: .red
                    )
                } else if stat.title == "Elevation" {
                    StatisticCard(
                        icon: "arrow.up.to.line",
                        statistic: stat,
                        iconColor: .green
                    )
                } else {
                    StatisticCard(statistic: stat)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct StatisticCard: View {
    var icon: String? = nil
    let statistic: Statistic
    var image1: String? = nil
    var image2: String? = nil
    var iconColor: Color = .secondary

    var body: some View {
        VStack {
            HStack {
                Text(statistic.title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                if let imageName1 = statistic.image1 {
                    Image(systemName: imageName1)
                        .foregroundColor(colorForIcon(imageName1))
                }
                Text(statistic.value1 ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            HStack {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                }
                let iconName = iconForStatistic(statistic.title)
                if !iconName.isEmpty {
                    Image(systemName: iconName)
                        .foregroundColor(colorForStatistic(statistic.title))
                }
                Text(statistic.value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let imageName2 = statistic.image2 {
                    Image(systemName: imageName2)
                        .foregroundColor(colorForIcon(imageName2))
                }
                Text(statistic.value2 ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(5)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(10)
    }

    func iconForStatistic(_ title: String) -> String {
        switch title {
        case "Max Speed":
            return "gauge.with.dots.needle.100percent"
        case "Distance":
            return "arrow.down.right"
        case "Min Elevation", "Total Vertical", "Altitude":
            return "mountain.2.circle"
        case "Duration", "Record Time":
            return "clock"
        case "Days":
            return "calendar.circle"
        default:
            return ""
        }
    }

    func colorForStatistic(_ title: String) -> Color {
        switch title {
        case "Max Speed":
            return .blue
        case "Distance":
            return .red
        case "Elevation", "Min Elevation", "Total Vertical", "Altitude", "Vertical":
            return .orange
        case "Duration":
            return .purple
        case "Days", "Record Time":
            return .red
        default:
            return .gray
        }
    }
    
     func colorForIcon(_ imageName: String?) -> Color {
         guard let imageName = imageName else { return .gray }

         switch imageName {
         case "arrow.up", "arrow.up.to.line", "arrow.up.right":
             return .green
         case "arrow.down", "arrow.down.to.line", "arrow.down.right":
             return .red
         case "arrow.up.and.down", "gauge.with.dots.needle.50percent":
             return .blue
         default:
             return .gray
         }
     }
}

struct EditTrackNameView: View {
    @ObservedObject var locationManager = LocationManager()
    @Binding var trackName: String
    var filePath: URL
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                TextField("Track Name", text: $trackName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer() // Spacer to push content to the top
            }
            .navigationBarTitle(Text("Edit Track Name"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    locationManager.updateTrackNameInFile(newName: trackName, filePath: filePath)
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
            .padding()
        }
    }
}
