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
    var totalElevationGain: Double?
    var totalDistance: Double?
    var recordingDuration: TimeInterval?
    var trackName: String?
}

// Extension for LocationManager to handle file operations
extension LocationManager {
    // Method to save location and tracking data to a file
    func saveLocationsToFile(trackName: String) {
        let codableLocations = locations.map { CodableLocation(location: $0) }
        let trackData = TrackData(
            maxSpeed: maxSpeed,
            locations: codableLocations,
            totalElevationGain: totalElevationGain,
            totalDistance: totalDistance,
            recordingDuration: recordingDuration,
            trackName: trackName
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Use ISO 8601 date format
        
        do {
            let jsonData = try encoder.encode(trackData)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let baseFileName = getUniqueFileName()
            let filePath = getDocumentsDirectory().appendingPathComponent("\(baseFileName).json")
            try jsonString.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
        // Reset tracking data
        resetTrackingData()
    }
    
    // Method to generate a unique file name
    private func getUniqueFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let baseFileName = "SnowCountry-Track-" + dateFormatter.string(from: Date())
        var finalFileName = baseFileName
        var fileCounter = 1

        while FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("\(finalFileName).json").path) {
            finalFileName = "\(baseFileName)_\(fileCounter)"
            fileCounter += 1
        }

        return finalFileName
    }

    // Method to get the Documents directory path
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
