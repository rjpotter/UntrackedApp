//
//  TrackToFile.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import SwiftUI
import CoreLocation

// Struct to encode individual locations
struct CodableLocation: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: String
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        // Format the date to a string
        let dateFormatter = ISO8601DateFormatter()
        self.timestamp = dateFormatter.string(from: location.timestamp)
    }
}

// Struct to encode track data with additional properties
struct TrackData: Codable {
    var maxSpeed: Double?
    var locations: [CodableLocation]
    var totalVertical: Double?
    var totalDistance: Double?
    var recordingDuration: TimeInterval?
    var trackName: String?
}

// Extension for LocationManager to handle file operations
extension LocationManager {
    func saveLocationsToFile(trackName: String? = nil) {
        // Start of the GPX file
        var gpxString = """
        <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
        <gpx version="1.1" creator="SnowCountry"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xmlns="http://www.topografix.com/GPX/1/1"
             xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
          <metadata>
            <name>\(trackName ?? "Untracked Track")</name>
            <time>\(ISO8601DateFormatter().string(from: Date()))</time>
          </metadata>
          <trk>
            <name>\(trackName ?? "Untracked Track")</name>
            <trkseg>
        """

        // Add track points
        for location in locations {
            let pointString = """
              <trkpt lat="\(location.coordinate.latitude)" lon="\(location.coordinate.longitude)">
                <ele>\(location.altitude)</ele>
                <time>\(ISO8601DateFormatter().string(from: location.timestamp))</time>
              </trkpt>
            """
            gpxString += pointString
        }

        // End of the GPX file
        gpxString += """
            </trkseg>
          </trk>
        </gpx>
        """

        // Save to file
        do {
            let baseFileName = getUniqueFileName()
            let filePath = getDocumentsDirectory().appendingPathComponent("\(baseFileName).gpx")
            try gpxString.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write GPX data: \(error.localizedDescription)")
        }

        // Reset tracking data
        resetTrackingData()
    }
    
    // Method to generate a unique file name
    private func getUniqueFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy_HHmm"
        let baseFileName = "Untracked-Track-" + dateFormatter.string(from: Date())
        var finalFileName = baseFileName
        var fileCounter = 1

        while FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("\(finalFileName).gpx").path) {
            finalFileName = "\(baseFileName)_\(fileCounter)"
            fileCounter += 1
        }

        return finalFileName
    }

    // Method to get the Documents directory path
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func updateTrackNameInFile(newName: String, filePath: URL) {
        do {
            var gpxContent = try String(contentsOf: filePath, encoding: .utf8)
            
            // Find and replace the first occurrence of the track name
            if let range = gpxContent.range(of: "<name>[^<]*</name>", options: .regularExpression) {
                gpxContent.replaceSubrange(range, with: "<name>\(newName)</name>")
            }

            // Write the updated GPX content back to the file
            try gpxContent.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to update track name: \(error)")
        }
    }
}
