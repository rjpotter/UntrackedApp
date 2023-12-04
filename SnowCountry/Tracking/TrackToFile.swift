//
//  TrackToFile.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import CoreLocation

struct CodableLocation: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = location.timestamp
    }
}

extension LocationManager {
    func saveLocationsToFile() {
        let codableLocations = locations.map { CodableLocation(location: $0) }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Use ISO 8601 date format
        
        do {
            let jsonData = try encoder.encode(codableLocations)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let baseFileName = getUniqueFileName()
            let filePath = getDocumentsDirectory().appendingPathComponent("\(baseFileName).json")
            try jsonString.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    
    private func getUniqueFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let baseFileName = dateFormatter.string(from: Date())
        var finalFileName = baseFileName
        var fileCounter = 1

        while FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("\(finalFileName).json").path) {
            finalFileName = "\(baseFileName)_\(fileCounter)"
            fileCounter += 1
        }

        return finalFileName
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}


