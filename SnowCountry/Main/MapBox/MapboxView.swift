//
//  MapboxMapView.swift
//  ArcGIS-Test
//
//  Created by Ryan Potter on 10/05/23.
// pk.eyJ1IjoicnBvdHRzMTE1IiwiYSI6ImNsbzB2N2JjczAyYzcydHBpNmI0cG0wOGsifQ.ogi5Ge4GEE-F44SLzyxcig

import SwiftUI
import MapboxMaps
import CoreLocation

struct MapboxView: UIViewRepresentable {
    @State private var userLocation: Location? = nil
    var userLocationProvider: UserLocationProvider
    @Binding var mapView: MapView?

    func makeUIView(context: Context) -> MapView {
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoicnBvdHRzMTE1IiwiYSI6ImNsbzB2N2JjczAyYzcydHBpNmI0cG0wOGsifQ.ogi5Ge4GEE-F44SLzyxcig")
        let options = MapInitOptions(resourceOptions: myResourceOptions, styleURI: StyleURI(rawValue: "mapbox://styles/rpotts115/clnzkqqpv00ah01qsgn6a2ibz"))
        let mapView = MapView(frame: CGRect.zero, mapInitOptions: options)
        context.coordinator.mapView = mapView
        self.mapView = mapView
        
        mapView.location.options.puckType = .puck2D()
        
        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        if let location = uiView.location.latestLocation, userLocation == nil {
            userLocation = location
            let cameraOptions = CameraOptions(center: location.coordinate, zoom: 15)
            uiView.camera.ease(to: cameraOptions, duration: 1.0)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var mapView: MapView?
        var userLocation: Location?

        func resetLocation() {
            if let location = userLocation {
                let cameraOptions = CameraOptions(center: location.coordinate, zoom: 15)
                mapView?.camera.ease(to: cameraOptions, duration: 1.0)
            }
        }
    }
}

extension CLLocation {
    static let significantDistanceThreshold: CLLocationDistance = 10

    func isSignificantlyDifferent(from otherLocation: CLLocation) -> Bool {
        return self.distance(from: otherLocation) > CLLocation.significantDistanceThreshold
    }
}
