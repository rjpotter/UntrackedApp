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
    @Published var totalUpDistance: Double = 0.0
    @Published var totalDownDistance: Double = 0.0
    @Published var currentSpeed: Double = 0.0 // Speed in meters per second
    @Published var maxSpeed: Double = 0.0 // Maximum speed in meters per second
    @Published var avgSpeed: Double = 0.0
    @Published var currentAltitude: Double = 0.0 // Current altitude in meters
    @Published var peakAltitude: Double = 0.0
    @Published var lowAltitude: Double = 0.0
    @Published var totalDownVertical: Double = 0.0 // Total elevation change in meters
    @Published var totalUpVertical: Double = 0.0 // Total elevation gain in meters
    @Published var deltaVertical: Double = 0.0 // Total elevation loss in meters
    @Published var recordingDuration: TimeInterval = 0 // Duration in seconds
    private var startTime: Date? // Start time of the recording
    let altitudeChangeThreshold: Double = 0.9
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
                var deltaVertical: Double = 0.0

                for i in 0..<smoothedElevations.count - 1 {
                    let startElevation = smoothedElevations[i]
                    let endElevation = smoothedElevations[i + 1]

                    let altitudeChange = abs(startElevation - endElevation)
                    if altitudeChange >= altitudeChangeThreshold {
                        deltaVertical += altitudeChange
                    }
                }
                print("Total Delta Vertical \(deltaVertical)")
                return isMetric ? deltaVertical : deltaVertical * 3.28084
            }

            // Function to calculate total vertical with moving average and threshold
            func calculateDownVertical(isMetric: Bool, windowSize: Int = 4, altitudeChangeThreshold: Double = 0.9) -> Double {
                let smoothedElevations = movingAverage(for: elevationData, windowSize: windowSize)
                var totalDownVertical: Double = 0.0

                for i in 0..<smoothedElevations.count - 1 {
                    let startElevation = smoothedElevations[i]
                    let endElevation = smoothedElevations[i + 1]

                    let altitudeChange = startElevation - endElevation
                    if abs(altitudeChange) >= altitudeChangeThreshold {
                        if endElevation < startElevation {
                            totalDownVertical += altitudeChange
                        }
                    }
                }
                print("Total Down Vertical: \(totalDownVertical)")
                return isMetric ? totalDownVertical : totalDownVertical * 3.28084
            }
            
            // Function to calculate total vertical with moving average and threshold
            func calculateUpVertical(isMetric: Bool, windowSize: Int = 4, altitudeChangeThreshold: Double = 0.9) -> Double {
                let smoothedElevations = movingAverage(for: elevationData, windowSize: windowSize)
                var totalUpVertical: Double = 0.0

                for i in 0..<smoothedElevations.count - 1 {
                    let startElevation = smoothedElevations[i]
                    let endElevation = smoothedElevations[i + 1]

                    let altitudeChange = endElevation - startElevation
                    if abs(altitudeChange) >= altitudeChangeThreshold {
                        if endElevation > startElevation {
                            totalUpVertical += altitudeChange
                        }
                    }
                }

                return isMetric ? totalUpVertical : totalUpVertical * 3.28084
            }
            
            func updateAltitudes(with newLocation: CLLocation) {
                    let newAltitude = newLocation.altitude
                    peakAltitude = max(peakAltitude, newAltitude)
                    lowAltitude = min(lowAltitude, newAltitude)
                
                    print(peakAltitude)
                }

                func calculateAverageSpeed() -> Double {
                    let totalDurationHours = recordingDuration / 3600  // Convert seconds to hours
                    return totalDistance / totalDurationHours  // Speed in m/s
                }

                func calculateMaxVerticalChange() -> Double {
                    var maxChange: Double = 0.0
                    for i in 1..<elevationData.count {
                        let change = abs(elevationData[i] - elevationData[i - 1])
                        maxChange = max(maxChange, change)
                    }
                    return maxChange
                }

                func calculateUphillDownhillDistance() -> (uphill: Double, downhill: Double) {
                    var uphillDistance: Double = 0.0
                    var downhillDistance: Double = 0.0

                    for i in 1..<locations.count {
                        let startLocation = locations[i - 1]
                        let endLocation = locations[i]
                        let distance = endLocation.distance(from: startLocation)

                        if endLocation.altitude > startLocation.altitude {
                            uphillDistance += distance
                        } else if endLocation.altitude < startLocation.altitude {
                            downhillDistance += distance
                        }
                    }

                    return (uphillDistance, downhillDistance)
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

