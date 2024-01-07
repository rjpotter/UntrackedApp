//
//  GPXStatsLogic.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/6/24.
//

import CoreLocation

// Calculate total distance from GPX locations (in kilometers or miles)
func calculateTotalDistance(locations: [CLLocation], isMetric: Bool) -> Double {
    var totalDistance: Double = 0.0
    for i in 0..<locations.count - 1 {
        let startLocation = locations[i]
        let endLocation = locations[i + 1]
        let distance = startLocation.distance(from: endLocation)
        totalDistance += isMetric ? distance / 1000.0 : distance / 1609.34
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

// Calculate total elevation loss from GPX locations (in meters or feet)
func calculateTotalElevationLoss(locations: [CLLocation], isMetric: Bool) -> Double {
    var totalElevationLoss: Double = 0.0

    for i in 0..<locations.count - 1 {
        let startElevation = locations[i].altitude
        let endElevation = locations[i + 1].altitude

        // Check for a decrease in elevation
        if endElevation < startElevation {
            let elevationLoss = startElevation - endElevation
            // Convert to feet if necessary
            totalElevationLoss += isMetric ? elevationLoss : elevationLoss * 3.28084
        }
    }

    return totalElevationLoss
}


func calculateMaxSpeed(locations: [CLLocation], isMetric: Bool) -> Double {
    var maxSpeed: Double = 0.0

    for i in 0..<locations.count - 1 {
        let startLocation = locations[i]
        let endLocation = locations[i + 1]
        let timeInterval = endLocation.timestamp.timeIntervalSince(startLocation.timestamp)

        if timeInterval > 0 {
            let distanceMeters = startLocation.distance(from: endLocation)
            let distance = isMetric ? distanceMeters / 1000.0 : distanceMeters * 0.000621371
            let speed = (distance / (timeInterval / 3600.0))

            if speed > maxSpeed {
                maxSpeed = speed
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
