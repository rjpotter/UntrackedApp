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
    @Published var totalVertical: Double = 0.0 // Total elevation gain in meters
    @Published var recordingDuration: TimeInterval = 0 // Duration in seconds
    private var startTime: Date? // Start time of the recording
    let altitudeChangeThreshold: Double = 5.0
    private var elevationData: [Double] = []

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Adjusted accuracy
        locationManager.distanceFilter = 15 // Adjusted distance filter
        locationManager.requestWhenInUseAuthorization()
        
        // For background location updates
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
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
    }

    func resetTrackingData() {
        locations.removeAll()
        totalDistance = 0.0
        maxSpeed = 0.0
        totalVertical = 0.0
        startTime = nil
        recordingDuration = 0
    }
    
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard let newLocation = newLocations.last else { return }
        
        elevationData.append(newLocation.altitude)

        // Update current speed and altitude
        currentSpeed = newLocation.speed
        currentAltitude = newLocation.altitude

        // Update max speed
        let roundedSpeed = newLocation.speed
        if roundedSpeed > maxSpeed {
            maxSpeed = roundedSpeed
        }

        // Add new location to the locations array
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            totalDistance += distance

            // Function to calculate total vertical with moving average and threshold
            func calculateTotalVertical(isMetric: Bool, windowSize: Int = 4, altitudeChangeThreshold: Double = 0.9) -> Double {
                let smoothedElevations = movingAverage(for: elevationData, windowSize: windowSize)
                var totalVertical: Double = 0.0

                for i in 0..<smoothedElevations.count - 1 {
                    let startElevation = smoothedElevations[i]
                    let endElevation = smoothedElevations[i + 1]

                    let altitudeChange = endElevation - startElevation
                    if abs(altitudeChange) >= altitudeChangeThreshold {
                        if endElevation > startElevation {
                            totalVertical += altitudeChange
                        }
                    }
                }

                return isMetric ? totalVertical : totalVertical * 3.28084
            }
        }

        self.lastLocation = newLocation
        self.locations.append(newLocation)
    }
}

extension LocationManager {
    func getTrackFiles() -> [String] {
        // List all files in the documents directory
        let documentsDirectory = getDocumentsDirectory()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            return fileURLs.map { $0.lastPathComponent }.filter { $0.hasSuffix(".json") || $0.hasSuffix(".gpx") }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            return []
        }
    }
}

