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

    // Tracking properties
    @Published var totalDistance: Double = 0.0
    @Published var totalUpDistance: Double = 0.0
    @Published var totalDownDistance: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var maxSpeed: Double = 0.0
    @Published var avgSpeed: Double = 0.0
    @Published var currentAltitude: Double = 0.0
    @Published var peakAltitude: Double = 0.0
    @Published var lowAltitude: Double = 0.0
    @Published var totalDownVertical: Double = 0.0
    @Published var totalUpVertical: Double = 0.0
    @Published var deltaVertical: Double = 0.0
    @Published var recordingDuration: TimeInterval = 0
    private var startTime: Date?
    private var elevationData: [Double] = []
    let altitudeChangeThreshold: Double = 0.9

    override init() {
        super.init()
        configureLocationManager()
    }

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 15
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
    }

    func startTracking() {
        startTime = Date()
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
        totalUpDistance = 0.0
        totalDownDistance = 0.0
        maxSpeed = 0.0
        avgSpeed = 0.0
        totalDownVertical = 0.0
        totalUpVertical = 0.0
        deltaVertical = 0.0
        currentAltitude = 0.0
        peakAltitude = 0.0
        lowAltitude = 0.0
        startTime = nil
        recordingDuration = 0
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard let newLocation = newLocations.last else { return }

        updateLocationData(with: newLocation)
    }

    private func updateLocationData(with newLocation: CLLocation) {
        // Update speed and altitude
        currentSpeed = newLocation.speed
        currentAltitude = newLocation.altitude
        updateMaxSpeed(with: newLocation.speed)
        updateAltitudes(with: newLocation)
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            totalDistance += distance
            processElevationData(newLocation.altitude)
        }

        lastLocation = newLocation
        locations.append(newLocation)
    }

    private func updateMaxSpeed(with speed: Double) {
        maxSpeed = max(maxSpeed, speed)
    }

    private func updateAltitudes(with newLocation: CLLocation) {
        peakAltitude = max(peakAltitude, newLocation.altitude)
        lowAltitude = min(lowAltitude, newLocation.altitude)
    }

    private func processElevationData(_ newAltitude: Double) {
        elevationData.append(newAltitude)
        // Implement additional elevation data processing here.
    }
}

// MARK: - Utility Functions
extension LocationManager {

// Speed
    func calculateAverageUphillSpeed(isMetric: Bool) -> Double {
        let uphillDistance = calculateUphillDistance(isMetric: isMetric) // Uphill distance in kilometers or miles
        let uphillTimeSeconds = calculateTimeSpentUphill() // Uphill time in seconds
        let uphillTimeHours = uphillTimeSeconds / 3600.0 // Convert time to hours

        if uphillTimeHours > 0.0 {
            return uphillDistance / uphillTimeHours // Speed in km/h or mph
        } else {
            return 0.0 // Return 0 if uphill time is zero
        }
    }
    
    func calculateAverageDownhillSpeed(isMetric: Bool) -> Double {
        let downhillDistance = calculateDownhillDistance(isMetric: isMetric) // in miles or kilometers
        let downhillTimeSeconds = calculateTimeSpentDownhill() // in seconds

        let downhillTimeHours = downhillTimeSeconds / 3600.0 // Convert time to hours

        if downhillDistance <= 0 || downhillTimeHours <= 0 {
            return 0.0
        } else {
            return downhillDistance / downhillTimeHours // Speed in mph or km/h
        }
    }
    
// Distance
    func calculateUphillDistance(isMetric: Bool) -> Double {
        var uphillDistance: Double = 0.0

        if locations.count > 1 {
            for i in 1..<locations.count {
                let startLocation = locations[i - 1]
                let endLocation = locations[i]
                let distance = endLocation.distance(from: startLocation)
                let convertedDistance = isMetric ? distance : distance * 0.000621371 // Convert to miles if needed
                
                if endLocation.altitude > startLocation.altitude {
                    uphillDistance += convertedDistance
                }
            }
        }

        return uphillDistance
    }

    func calculateDownhillDistance(isMetric: Bool) -> Double {
        var downhillDistanceMeters: Double = 0.0

        if locations.count > 1 {
            for i in 1..<locations.count {
                let startLocation = locations[i - 1]
                let endLocation = locations[i]
                
                if endLocation.altitude < startLocation.altitude {
                    downhillDistanceMeters += endLocation.distance(from: startLocation)
                }
            }
        }

        // Convert total downhill distance from meters to kilometers or miles
        return isMetric ? downhillDistanceMeters / 1000.0 : downhillDistanceMeters * 0.000621371
    }


// Vertical
    func calculateVerticalLoss(isMetric: Bool) -> Double {
        var totalLoss: Double = 0.0

        if locations.count > 1 {
            for i in 1..<locations.count {
                let startAltitude = locations[i - 1].altitude
                let endAltitude = locations[i].altitude
                if endAltitude < startAltitude {
                    totalLoss += startAltitude - endAltitude
                }
            }
        }
        return isMetric ? totalLoss : totalLoss * 3.28084 // Convert to feet if needed
    }
    
    func calculateVerticalGain(isMetric: Bool) -> Double {
        var totalGain: Double = 0.0

        if locations.count > 1 {
            for i in 1..<locations.count {
                let startAltitude = locations[i - 1].altitude
                let endAltitude = locations[i].altitude
                if endAltitude > startAltitude {
                    totalGain += endAltitude - startAltitude
                }
            }
        }

        return isMetric ? totalGain : totalGain * 3.28084 // Convert to feet if needed
    }

    
    func calculateVerticalChange(isMetric: Bool) -> Double {
        var totalChange: Double = 0.0

        if locations.count > 1 {
            for i in 1..<locations.count {
                let startAltitude = locations[i - 1].altitude
                let endAltitude = locations[i].altitude
                totalChange += abs(endAltitude - startAltitude)
            }
        }

        return isMetric ? totalChange : totalChange * 3.28084 // Convert to feet if needed
    }

    
// Altitude
    func calculateMaxAltitude(isMetric: Bool) -> Double {
        let maxAltitude = locations.max(by: { $0.altitude < $1.altitude })?.altitude ?? 0.0
        return isMetric ? maxAltitude : maxAltitude * 3.28084 // Convert to feet if imperial
    }
    
    func calculateMinAltitude(isMetric: Bool) -> Double {
        let minAltitude = locations.min(by: { $0.altitude < $1.altitude })?.altitude ?? 0.0
        return isMetric ? minAltitude : minAltitude * 3.28084 // Convert to feet if imperial
    }
    
// Time
    func calculateTimeSpentDownhill() -> TimeInterval {
        var totalTimeDownhill: TimeInterval = 0.0
        
        if locations.count > 1 {
            for i in 1..<locations.count {
                let startLocation = locations[i - 1]
                let endLocation = locations[i]
                
                if endLocation.altitude < startLocation.altitude {
                    totalTimeDownhill += endLocation.timestamp.timeIntervalSince(startLocation.timestamp)
                }
            }
        }

        return totalTimeDownhill
    }
    
    func calculateTimeSpentUphill() -> TimeInterval {
        var totalTimeUphill: TimeInterval = 0.0
        
        if locations.count > 1 {
            for i in 1..<locations.count {
                let startLocation = locations[i - 1]
                let endLocation = locations[i]
                
                if endLocation.altitude > startLocation.altitude {
                    totalTimeUphill += endLocation.timestamp.timeIntervalSince(startLocation.timestamp)
                }
            }
        }

        return totalTimeUphill
    }
}

// MARK: - File Management
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
