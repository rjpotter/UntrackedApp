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

// Calculate total Up distance from GPX locations (in kilometers or miles)
func calculateTotalUpDistance(locations: [CLLocation], isMetric: Bool) -> Double {
    var totalUpDistance: Double = 0.0
    // Ensure there are at least two locations to calculate distance
    if locations.count >= 2 {
        for i in 0..<locations.count - 1 {
            let startLocation = locations[i]
            let endLocation = locations[i + 1]
            if startLocation.altitude < endLocation.altitude {
                let distance = startLocation.distance(from: endLocation)
                totalUpDistance += isMetric ? distance / 1000.0 : distance / 1609.34
            }
        }
    }
    return totalUpDistance
}

// Calculate total Down distance from GPX locations (in kilometers or miles)
func calculateTotalDownDistance(locations: [CLLocation], isMetric: Bool) -> Double {
    var totalDownDistance: Double = 0.0
    // Ensure there are at least two locations to calculate distance
    if locations.count >= 2 {
        for i in 0..<locations.count - 1 {
            let startLocation = locations[i]
            let endLocation = locations[i + 1]
            if startLocation.altitude > endLocation.altitude {
                let distance = startLocation.distance(from: endLocation)
                totalDownDistance += isMetric ? distance / 1000.0 : distance / 1609.34
            }
        }
    }
    return totalDownDistance
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

func calculateTotalElevationLoss(locations: [CLLocation], isMetric: Bool, windowSize: Int = 3) -> Double {
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

func calculateTotalElevationGain(locations: [CLLocation], isMetric: Bool, windowSize: Int = 3) -> Double {
    let elevations = locations.map { $0.altitude }
    let smoothedElevations = movingAverage(for: elevations, windowSize: windowSize)

    var totalElevationGain: Double = 0.0
    let elevationGainThreshold: Double = 0.9 // Set your threshold value

    // Ensure there are at least two elements in smoothedElevations
    if smoothedElevations.count >= 2 {
        for i in 0..<smoothedElevations.count - 1 {
            let startElevation = smoothedElevations[i]
            let endElevation = smoothedElevations[i + 1]

            // Check for a decrease in elevation
            let elevationChange = endElevation - startElevation
            if elevationChange > elevationGainThreshold {
                // Convert to feet if necessary
                let deltaElevation = isMetric ? elevationChange : elevationChange * 3.28084
                totalElevationGain += deltaElevation
            }
        }
    }

    return totalElevationGain
}

func calculateTotalElevationChange(locations: [CLLocation], isMetric: Bool, windowSize: Int = 3) -> Double {
    let elevations = locations.map { $0.altitude }
    let smoothedElevations = movingAverage(for: elevations, windowSize: windowSize)

    var totalElevationChange: Double = 0.0
    let elevationChangeThreshold: Double = 0.9 // Set your threshold value

    // Ensure there are at least two elements in smoothedElevations
    if smoothedElevations.count >= 2 {
        for i in 0..<smoothedElevations.count - 1 {
            let startElevation = smoothedElevations[i]
            let endElevation = smoothedElevations[i + 1]

            var elevationChange = 0.0
            // Check for a decrease in elevation
            if endElevation > startElevation {
                elevationChange = endElevation - startElevation
            } else if endElevation < startElevation {
                elevationChange = startElevation - endElevation
            }
            if elevationChange > elevationChangeThreshold {
                // Convert to feet if necessary
                let elevationChange = isMetric ? elevationChange : elevationChange * 3.28084
                totalElevationChange += elevationChange
            }
        }
    }

    return totalElevationChange
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

func calculateUphillAvgSpeed(locations: [CLLocation], isMetric: Bool) -> Double {
    var totalUphillSpeeds: Double = 0.0
    var uphillSegments: Int = 0

    if locations.count >= 2 {
        var i = 0
        while i < locations.count - 1 {
            if locations[i].altitude < locations[i + 1].altitude {
                // Start of an uphill segment
                var segmentDistance: Double = 0.0
                var segmentTime: TimeInterval = 0.0

                var j = i
                while j < locations.count - 1 && locations[j].altitude < locations[j + 1].altitude {
                    let timeInterval = locations[j + 1].timestamp.timeIntervalSince(locations[j].timestamp)
                    if timeInterval > 0 {
                        segmentDistance += locations[j].distance(from: locations[j + 1])
                        segmentTime += timeInterval
                    }
                    j += 1
                }

                // Calculate average speed for this segment
                if segmentTime > 0 {
                    let segmentSpeed = segmentDistance / segmentTime * (isMetric ? 3.6 : 2.23694) // Convert to km/h or mph
                    totalUphillSpeeds += segmentSpeed
                    uphillSegments += 1
                }

                // Move to the next segment
                i = j
            } else {
                i += 1
            }
        }
    }

    // Calculate overall average uphill speed
    if uphillSegments > 0 {
        return totalUphillSpeeds / Double(uphillSegments)
    }

    return 0.0 // Return 0 if there's no data to calculate average uphill speed
}

func calculateDownhillAvgSpeed(locations: [CLLocation], isMetric: Bool) -> Double {
    var totalDownhillSpeeds: Double = 0.0
    var downhillSegments: Int = 0

    if locations.count >= 2 {
        var i = 0
        while i < locations.count - 1 {
            if locations[i].altitude > locations[i + 1].altitude {
                // Start of a downhill segment
                var segmentDistance: Double = 0.0
                var segmentTime: TimeInterval = 0.0

                var j = i
                while j < locations.count - 1 && locations[j].altitude > locations[j + 1].altitude {
                    let timeInterval = locations[j + 1].timestamp.timeIntervalSince(locations[j].timestamp)
                    if timeInterval > 0 {
                        segmentDistance += locations[j].distance(from: locations[j + 1])
                        segmentTime += timeInterval
                    }
                    j += 1
                }

                // Calculate average speed for this segment
                if segmentTime > 0 {
                    let segmentSpeed = segmentDistance / segmentTime * (isMetric ? 3.6 : 2.23694) // Convert to km/h or mph
                    totalDownhillSpeeds += segmentSpeed
                    downhillSegments += 1
                }

                // Move to the next segment
                i = j
            } else {
                i += 1
            }
        }
    }

    // Calculate overall average downhill speed
    if downhillSegments > 0 {
        return totalDownhillSpeeds / Double(downhillSegments)
    }

    return 0.0 // Return 0 if there's no data to calculate average downhill speed
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
    formatter.zeroFormattingBehavior = .pad

    return formatter.string(from: duration) ?? "0s"
}

// Calculate total duration from GPX locations (in seconds)
func calculateDuration(locations: [CLLocation]) -> TimeInterval {
    guard let firstLocation = locations.first, let lastLocation = locations.last else {
        return 0
    }
    return lastLocation.timestamp.timeIntervalSince(firstLocation.timestamp)
}

func calculateTimeSpentUphill(locations: [CLLocation]) -> TimeInterval {
    var totalTimeUphill: TimeInterval = 0.0

    if locations.count >= 2 {
        for i in 0..<locations.count - 1 {
            if locations[i + 1].altitude > locations[i].altitude {
                let timeInterval = locations[i + 1].timestamp.timeIntervalSince(locations[i].timestamp)
                totalTimeUphill += timeInterval
            }
        }
    }

    return totalTimeUphill
}

func calculateTimeSpentDownhill(locations: [CLLocation]) -> TimeInterval {
    var totalTimeDownhill: TimeInterval = 0.0

    if locations.count >= 2 {
        for i in 0..<locations.count - 1 {
            if locations[i + 1].altitude < locations[i].altitude {
                let timeInterval = locations[i + 1].timestamp.timeIntervalSince(locations[i].timestamp)
                totalTimeDownhill += timeInterval
            }
        }
    }

    return totalTimeDownhill
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
