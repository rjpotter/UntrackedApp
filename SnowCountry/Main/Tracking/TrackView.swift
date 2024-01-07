//
//  TrackView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/24/23.
//

import SwiftUI
import MapKit

struct TrackView: View {
    var locations: [CLLocation]
    @State private var trackViewMap = MKMapView()  // State variable for MKMapView

    var body: some View {
        TrackViewMap(trackViewMap: $trackViewMap, locations: locations)
    }
}

struct TrackViewMap: UIViewRepresentable {
    @Binding var trackViewMap: MKMapView
    var locations: [CLLocation]
    private let button = UIButton(type: .system)
    var polyline = MKPolyline()
    
    func makeUIView(context: Context) -> MKMapView {
        trackViewMap.delegate = context.coordinator
        trackViewMap.showsUserLocation = true
        configureButton(mapView: trackViewMap, coordinator: context.coordinator)
        
        // Add the initial polyline overlay
        trackViewMap.addOverlay(polyline)
        
        return trackViewMap
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateMap(uiView)
    }
    
    private func updateMap(_ mapView: MKMapView) {
        let coordinates = locations.map { $0.coordinate }
        
        // Clear existing overlays
        mapView.removeOverlays(mapView.overlays)
        
        // Create and add updated polyline
        let updatedPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(updatedPolyline)
    }
    
    private func configureButton(mapView: MKMapView, coordinator: Coordinator) {
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = .blue
        button.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        button.layer.cornerRadius = 15
        button.addTarget(coordinator, action: #selector(Coordinator.centerMapOnUserLocation), for: .touchUpInside)
        
        mapView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for positioning the button in the bottom right corner
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20), // 20 points from the right edge
            button.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 20), // 20 points from the top edge
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TrackViewMap
        
        init(_ parent: TrackViewMap) {
            self.parent = parent
        }
        
        @objc func centerMapOnUserLocation() {
            if let userLocation = parent.trackViewMap.userLocation.location {
                let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                parent.trackViewMap.setRegion(region, animated: true)
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .red
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
