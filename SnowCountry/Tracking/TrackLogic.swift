//
//  TrackLogic.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locations: [CLLocation] = []
    private var lastLocation: CLLocation?

    // Additional tracking properties
    @Published var totalDistance: Double = 0.0 // Total distance in meters
    @Published var currentSpeed: Double = 0.0 // Speed in meters per second
    @Published var maxSpeed: Double = 0.0 // Maximum speed in meters per second
    @Published var currentAltitude: Double = 0.0 // Current altitude in meters
    @Published var totalElevationGain: Double = 0.0 // Total elevation gain in meters
    @Published var recordingDuration: TimeInterval = 0 // Duration in seconds
    private var startTime: Date? // Start time of the recording

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3
        locationManager.requestWhenInUseAuthorization()
        
        // For background location updates
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func startTracking() {
        startTime = Date() // Set the start time
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        if let startTime = startTime {
            recordingDuration = Date().timeIntervalSince(startTime)
        }
        saveLocationsToFile()
        // Reset tracking data
        resetTrackingData()
    }

    private func resetTrackingData() {
        totalDistance = 0.0
        maxSpeed = 0.0
        totalElevationGain = 0.0
        startTime = nil
        recordingDuration = 0
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard let newLocation = newLocations.last else { return }

        // Update current speed and altitude
        currentSpeed = round(newLocation.speed * 10) / 10 // Round to 1 decimal place
        currentAltitude = round(newLocation.altitude * 10) / 10

        // Update max speed
        let roundedSpeed = round(newLocation.speed * 10) / 10
        if roundedSpeed > maxSpeed {
            maxSpeed = roundedSpeed
        }
            
            print("Current Speed: \(newLocation.speed)")
            print("Max Speed: \(maxSpeed)")

        // Add new location to the locations array
        if let lastLocation = lastLocation {
            let distance = round(newLocation.distance(from: lastLocation) * 10) / 10
            totalDistance += distance

            // Calculate elevation gain
            if newLocation.altitude > lastLocation.altitude {
                totalElevationGain += round((newLocation.altitude - lastLocation.altitude) * 10) / 10
            }
        }

        self.lastLocation = newLocation
        self.locations.append(newLocation)
    }
}

// Extension methods...
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

