//
//  LifetimeStats.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/12/24.
//

import SwiftUI

class LifetimeStats: ObservableObject {
    @Published var totalDays: Int = 0
    @Published var totalVertical: Double = 0.0
    @Published var totalDistance: Double = 0.0
    @Published var topSpeed: Double = 0.0
    @Published var totalRecordingTime: TimeInterval = 0.0
    @Published var maxElevation: Double = 0.0
    @Published var totalDuration: TimeInterval = 0.0

    // Add any other properties you need to track
    // You can also add methods here if you need to perform any calculations or operations on the data
}
