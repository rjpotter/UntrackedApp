//
//  TrackHistoryView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.
//

import SwiftUI
import MapKit

struct TrackHistoryViewMap: UIViewRepresentable {
    @Binding var trackHistoryViewMap: MKMapView
    var locations: [CLLocation]
    
    func makeUIView(context: Context) -> MKMapView {
        trackHistoryViewMap.delegate = context.coordinator
        trackHistoryViewMap.showsUserLocation = false
        return trackHistoryViewMap
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
        var parent: TrackHistoryViewMap

        init(_ parent: TrackHistoryViewMap) {
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
