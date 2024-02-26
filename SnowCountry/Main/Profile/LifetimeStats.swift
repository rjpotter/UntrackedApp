//
//  LifetimeStats.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/12/24.
//

import SwiftUI

class LifetimeStats: ObservableObject {
    @Published var totalDays: Int = 0 {
        didSet { print("Updated totalDays: \(totalDays)") }
    }
    @Published var totalDownVertical: Double = 0.0 {
        didSet { print("Updated totalVertical: \(totalDownVertical)") }
    }
    @Published var totalDownDistance: Double = 0.0 {
        didSet { print("Updated totalDistance: \(totalDownDistance)") }
    }
    @Published var topSpeed: Double = 0.0 {
        didSet { print("Updated topSpeed: \(topSpeed)") }
    }
    @Published var totalRecordingTime: TimeInterval = 0.0 {
        didSet { print("Updated totalRecordingTime: \(totalRecordingTime)") }
    }
    @Published var maxElevation: Double = 0.0 {
        didSet { print("Updated maxElevation: \(maxElevation)") }
    }
    @Published var totalDuration: TimeInterval = 0.0 {
        didSet { print("Updated totalDuration: \(totalDuration)") }
    }
}
