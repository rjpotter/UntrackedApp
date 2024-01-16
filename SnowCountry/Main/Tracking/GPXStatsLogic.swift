//
//  GPXStatsLogic.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/6/24.
//

import CoreLocation
let elevationLossThreshold: Double = 5.0

// Calculate total distance from GPX locations (in kilometers or miles)
func calculateTotalDistance(locations: [CLLocation], isMetric: Bool) -> Double {
    var totalDistance: Double = 0.0
    // Ensure there are at least two locations to calculate distance
    if locations.count >= 2 {
        for i in 0..<locations.count - 1 {
            let startLocation = locations[i]
            let endLocation = locations[i + 1]
            let distance = startLocation.distance(from: endLocation)
            totalDistance += isMetric ? distance / 1000.0 : distance / 1609.34
        }
    }
    return totalDistance
}

// Calculate maximum elevation from GPX locations (in meters or feet)
func calculateMaxElevation(locations: [CLLocation], isMetric: Bool) -> Double {
    var maxElevation: Double = 0.0
    for location in locations {
        let elevation = isMetric ? location.altitude : location.altitude * 3.28084
        if elevation > maxElevation {
            maxElevation = elevation
        }
    }
    return maxElevation
}

// Calculate minimum elevation from GPX locations (in meters or feet)
func calculateMinElevation(locations: [CLLocation], isMetric: Bool) -> Double {
    guard !locations.isEmpty else {
        return 0.0
    }

    var minElevation: Double = locations.first!.altitude
    for location in locations {
        let elevation = location.altitude
        if elevation < minElevation {
            minElevation = elevation
        }
    }
    return isMetric ? minElevation : minElevation * 3.28084
}


// Calculate total duration from GPX locations (in seconds)
func calculateDuration(locations: [CLLocation]) -> TimeInterval {
    guard let firstLocation = locations.first, let lastLocation = locations.last else {
        return 0
    }
    return lastLocation.timestamp.timeIntervalSince(firstLocation.timestamp)
}

func calculateTotalElevationLoss(locations: [CLLocation], isMetric: Bool, windowSize: Int = 4) -> Double {
    let elevations = locations.map { $0.altitude }
    let smoothedElevations = movingAverage(for: elevations, windowSize: windowSize)

    var totalElevationLoss: Double = 0.0
    let elevationLossThreshold: Double = 0.9 // Set your threshold value

    // Ensure there are at least two elements in smoothedElevations
    if smoothedElevations.count >= 2 {
        for i in 0..<smoothedElevations.count - 1 {
            let startElevation = smoothedElevations[i]
            let endElevation = smoothedElevations[i + 1]

            // Check for a decrease in elevation
            let elevationChange = startElevation - endElevation
            if elevationChange > elevationLossThreshold {
                // Convert to feet if necessary
                let elevationLoss = isMetric ? elevationChange : elevationChange * 3.28084
                totalElevationLoss += elevationLoss
            }
        }
    }

    return totalElevationLoss
}

func calculateMaxSpeed(locations: [CLLocation], isMetric: Bool) -> Double {
    var maxSpeed: Double = 0.0

    // Ensure there are at least two locations to calculate speed
    if locations.count >= 2 {
        for i in 0..<locations.count - 1 {
            let startLocation = locations[i]
            let endLocation = locations[i + 1]
            let timeInterval = endLocation.timestamp.timeIntervalSince(startLocation.timestamp)

            if timeInterval > 0 {
                let distanceMeters = startLocation.distance(from: endLocation)
                let distance = isMetric ? distanceMeters / 1000.0 : distanceMeters * 0.000621371
                let speed = distance / (timeInterval / 3600.0)

                if speed > maxSpeed {
                    maxSpeed = speed
                }
            }
        }
    }
    return maxSpeed
}

// Calculate max altitude from GPX locations (in meters or feet)
func calculateMaxAltitude(locations: [CLLocation], isMetric: Bool) -> Double {
    var maxAltitude: Double = -Double.infinity
    for location in locations {
        let altitude = isMetric ? location.altitude : location.altitude * 3.28084
        if altitude > maxAltitude {
            maxAltitude = altitude
        }
    }
    return maxAltitude
}

func formatDuration(_ duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: duration) ?? "0s"
}

// Function to apply a moving average filter to the elevation data
func movingAverage(for elevations: [Double], windowSize: Int) -> [Double] {
    guard elevations.count > windowSize else { return elevations }
    var smoothedElevations = [Double]()
    var window = [Double]()

    for elevation in elevations {
        window.append(elevation)
        if window.count > windowSize {
            window.removeFirst()
        }

        let average = window.reduce(0, +) / Double(window.count)
        smoothedElevations.append(average)
    }

    return smoothedElevations
}
