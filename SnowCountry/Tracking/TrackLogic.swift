//
//  TrackLogic.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locations: [CLLocation] = []
    private var lastLocation: CLLocation? // To track the last updated location

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3 // Update every 3 meters
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        saveLocationsToFile()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard let newLocation = newLocations.last else { return }

        // Check if the new location is significantly different from the last location
        if let lastLocation = lastLocation, newLocation.distance(from: lastLocation) < 3 {
            // If the distance is less than 10 meters, it's not a significant movement, so ignore
            return
        }

        self.lastLocation = newLocation // Update the last location
        self.locations.append(newLocation) // Add to tracked locations
    }
}

extension LocationManager {
    func getTrackFiles() -> [String] {
        // List all files in the documents directory
        let documentsDirectory = getDocumentsDirectory()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            return fileURLs.map { $0.lastPathComponent }.filter { $0.hasSuffix(".json") }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            return []
        }
    }
}

