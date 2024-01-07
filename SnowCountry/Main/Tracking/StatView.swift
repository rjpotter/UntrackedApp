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
                if let error = loadingError {
                    Text("Error loading track: \(error)")
                        .foregroundColor(.red)
                }
                VStack {
                    // Extract track name or use date from file name
                    let trackName = trackData?.trackName ?? defaultTrackName(from: trackFilePath)
                    Text(trackName)
                        .font(.largeTitle)
                        .padding(.top)
                    
                    TrackHistoryViewMap(trackHistoryViewMap: $trackHistoryViewMap, locations: locations)
                        .frame(height: 300)
                        .cornerRadius(15)
                        .padding()

                    // Statistics in a grid - handle cases for both JSON and GPX
                    if let trackData = trackData {
                        let statistics = createStatistics(isMetric: isMetric, trackData: trackData)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(statistics, id: \.self) { stat in
                                StatisticCard(statistic: stat)
                            }
                        }
                        .padding()
                    } else if !locations.isEmpty {
                        // Handle statistics display for GPX files if needed
                        // You may need to modify how you create statistics for GPX
                    }
                }
            }
        }
        .onAppear(perform: { loadTrackData() })
    }

    private func loadTrackData() {
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
                locations = parseGPX(gpxString)
            }
        } catch {
            loadingError = error.localizedDescription
        }
        isLoading = false
        updateMapViewWithLocations()
    }

    private func parseGPX(_ gpxString: String) -> [CLLocation] {

        let xmlParser = XMLParser(data: Data(gpxString.utf8))
        let gpxParserDelegate = GPXParserDelegate()
        xmlParser.delegate = gpxParserDelegate

        xmlParser.parse()
        return gpxParserDelegate.foundLocations
    }

    class GPXParserDelegate: NSObject, XMLParserDelegate {
        var foundLocations: [CLLocation] = []
        private var currentLatitude: Double?
        private var currentLongitude: Double?

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
            if elementName == "trkpt", let latStr = attributeDict["lat"], let lonStr = attributeDict["lon"], let lat = Double(latStr), let lon = Double(lonStr) {
                currentLatitude = lat
                currentLongitude = lon
            }
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            if elementName == "trkpt", let lat = currentLatitude, let lon = currentLongitude {
                let location = CLLocation(latitude: lat, longitude: lon)
                foundLocations.append(location)
                currentLatitude = nil
                currentLongitude = nil
            }
        }
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

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }

    private func createStatistics(isMetric: Bool, trackData: TrackData) -> [Statistic] {
        let speed = (isMetric ? (trackData.maxSpeed ?? 0) : (trackData.maxSpeed ?? 0) * 2.23694).rounded(toPlaces: 1)
        let distance = (isMetric ? (trackData.totalDistance ?? 0) / 1000 : (trackData.totalDistance ?? 0) * 0.000621371).rounded(toPlaces: 1)
        let vertical = (isMetric ? (trackData.totalVertical ?? 0) : (trackData.totalVertical ?? 0) * 3.28084).rounded(toPlaces: 1)

        return [
            Statistic(title: "Max Speed", value: "\(speed) \(isMetric ? "km/h" : "mph")"),
            Statistic(title: "Total Distance", value: "\(distance) \(isMetric ? "km" : "mi")"),
            Statistic(title: "Vertical", value: "\(vertical) \(isMetric ? "meters" : "feet")"),
            Statistic(title: "Duration", value: formatDuration(trackData.recordingDuration ?? 0))
        ]
    }
}

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
