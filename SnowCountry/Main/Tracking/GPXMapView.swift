//
//  GPXMapView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/6/24.
//

import SwiftUI
import MapKit

struct GPXMapView: UIViewRepresentable {
    var locations: [CLLocation]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        updateMap(mapView)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateMap(uiView)
    }

    private func updateMap(_ mapView: MKMapView) {
        guard !locations.isEmpty else {
            return
        }

        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyline)
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: GPXMapView

        init(_ parent: GPXMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
