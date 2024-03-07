//
//  TrackImageMapView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 3/6/24.
//

import SwiftUI
import MapKit

struct TrackImageMapView: UIViewRepresentable {
    var locations: [CLLocation]
    @Binding var selectedMapStyle: MapStyle

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        updateMapStyle(mapView)
        
        // Disable user interactions to lock the map view on the track
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateMapView(uiView)
        updateMapStyle(uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func updateMapView(_ mapView: MKMapView) {
        guard !locations.isEmpty else {
            return
        }

        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)

        // Create polyline
        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        // Add polyline to map
        mapView.addOverlay(polyline)
        
        // Adjust the map region to fit the polyline with padding
        let padding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50) // Adjust the padding as needed
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: padding, animated: true)
    }
    
    private func updateMapStyle(_ mapView: MKMapView) {
        switch selectedMapStyle {
        case .normal:
            mapView.mapType = .standard
        case .satellite:
            mapView.mapType = .satellite
        case .hybrid:
            mapView.mapType = .hybridFlyover
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TrackImageMapView

        init(_ parent: TrackImageMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .orange
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
