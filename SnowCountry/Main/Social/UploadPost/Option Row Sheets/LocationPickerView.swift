//
//  LocationPickerView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/25/24.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @State private var searchText: String = ""
    @State private var selectedLocation: String = "" // Displayed location name
    @State private var coordinate: CLLocationCoordinate2D? // Selected coordinate
    
    var body: some View {
        VStack {
            TextField("Name the location...", text: $selectedLocation)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .padding()

            if let _ = coordinate {
                Text("Location Selected")
                    .font(.headline)
                    .padding()
            }
            
            LocationPickerMapView(selectedCoordinate: $coordinate, selectedLocationName: $selectedLocation)
                .frame(height: 300)
                .cornerRadius(10)
                .padding()
            
            Button(action: {
                // Save or pass the location information
            }) {
                Text("Save Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
}
