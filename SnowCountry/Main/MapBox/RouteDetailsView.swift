//
//  RouteDetailsView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/8/23.
//

import SwiftUI
import MapboxMaps
import CoreLocation

struct RouteDetailsView: View {
    var route: CustomRoute

    var body: some View {
        // Display route details
        VStack {
            Text(route.name).font(.title)
            Text("Total Elevation Gain: \(route.totalElevationGain) meters")
            Text("Total Elevation Loss: \(route.totalElevationLoss) meters")
            Text("Distance: \(route.distance) meters")
            Text("Steepest Grade: \(route.steepestGrade)%")
            // Add more details as needed
        }
        .padding()
    }
}
