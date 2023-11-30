//
//  TrackHistoryView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.
//

import SwiftUI
import MapKit

struct TrackHistoryView: View {
    var trackFile: String // The name of the file to read

    @State private var trackHistoryViewMap = MKMapView()
    @State private var locations: [CLLocation] = []

    var body: some View {
        TrackHistoryViewMap(trackHistoryViewMap: $trackHistoryViewMap, locations: locations)
            .onAppear {
                loadTrackData()
            }
    }
    
    private func loadTrackData() {
        let fileURL = LocationManager().getDocumentsDirectory().appendingPathComponent("\(trackFile)")
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let fileToTracks = try decoder.decode([FileToTrack].self, from: data)
            self.locations = fileToTracks.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
            print("Loaded \(fileToTracks.count) locations from \(trackFile)")
        } catch {
            print("Error loading track data: \(error)")
            print("Error loading track data: \(error)")
        }
    }
}

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
                renderer.strokeColor = .red
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
