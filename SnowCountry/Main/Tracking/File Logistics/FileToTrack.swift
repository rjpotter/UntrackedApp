//
//  FileToTrack.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.
//

import Foundation
import CoreLocation

struct FileToTrack: Decodable {
    // Define properties to represent the data in your JSON file
    // For example, if your JSON has latitude, longitude, and timestamp fields:
    let trackName: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
    let maxSpeed: Double
    let totalDistance: Double
    let totalVertical: Double
    let recordingDuration: TimeInterval
}
