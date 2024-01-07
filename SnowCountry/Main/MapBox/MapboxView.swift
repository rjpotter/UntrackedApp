//
//  MapboxMapView.swift
//  ArcGIS-Test
//
//  Created by Ryan Potter on 10/05/23.
// pk.eyJ1IjoicnBvdHRzMTE1IiwiYSI6ImNsbzB2N2JjczAyYzcydHBpNmI0cG0wOGsifQ.ogi5Ge4GEE-F44SLzyxcig
//let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoicnBvdHRzMTE1IiwiYSI6ImNsbzB2N2JjczAyYzcydHBpNmI0cG0wOGsifQ.ogi5Ge4GEE-F44SLzyxcig")
//let options = MapInitOptions(resourceOptions: myResourceOptions, styleURI: StyleURI(rawValue: "mapbox://styles/rpotts115/clnzkqqpv00ah01qsgn6a2ibz"))

import SwiftUI
import MapboxMaps
import CoreLocation

struct MapboxView: UIViewRepresentable {
    @State private var userLocation: Location? = nil
    @Binding var mapView: MapView?
    @Binding var isRadarOverlayVisible: Bool
    @Binding var isSnowDepthOverlayVisible: Bool
    @Binding var isSnowForecastOverlayVisible: Bool
    @Binding var isCloudCoverOverlayVisible: Bool

    func makeUIView(context: Context) -> MapView {
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoicnBvdHRzMTE1IiwiYSI6ImNsbzB2N2JjczAyYzcydHBpNmI0cG0wOGsifQ.ogi5Ge4GEE-F44SLzyxcig")
        let options = MapInitOptions(resourceOptions: myResourceOptions, styleURI: StyleURI(rawValue: "mapbox://styles/rpotts115/clnzkqqpv00ah01qsgn6a2ibz"))
        let mapView = MapView(frame: CGRect.zero, mapInitOptions: options)
        context.coordinator.mapView = mapView
        self.mapView = mapView
        
        mapView.location.options.puckType = .puck2D()
        updateWeatherOverlay(for: mapView, with: context.coordinator)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        updateWeatherOverlay(for: uiView, with: context.coordinator)
    }

    private func updateWeatherOverlay(for mapView: MapView, with coordinator: Coordinator) {
        if isRadarOverlayVisible {
            coordinator.addOverlay(to: mapView, type: .radar)
        } else if isSnowDepthOverlayVisible {
            coordinator.addOverlay(to: mapView, type: .snowDepth)
        } else if isSnowForecastOverlayVisible {
            coordinator.addOverlay(to: mapView, type: .snowForecast)
        } else if isCloudCoverOverlayVisible {
            coordinator.addOverlay(to: mapView, type: .cloudCover)
        } else {
            coordinator.removeOverlay(from: mapView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var mapView: MapView?

        enum OverlayType {
            case radar, snowDepth, snowForecast, cloudCover
        }

        func addOverlay(to mapView: MapView, type: OverlayType) {
            var source = RasterSource()
            switch type {
                case .radar:
                    source.tiles = ["https://maps.aerisapi.com/dm5iXYHKxhkIbBId8DzXP_kB3uMtbZhAt6dbf3tw4gW9CkPRb8Abzyfxb6eXXB/radar-global/{z}/{x}/{y}/current.png"]
                case .snowDepth:
                    source.tiles = ["https://maps.aerisapi.com/dm5iXYHKxhkIbBId8DzXP_kB3uMtbZhAt6dbf3tw4gW9CkPRb8Abzyfxb6eXXB/snow-depth/{z}/{x}/{y}/current.png"]
                case .snowForecast:
                    source.tiles = ["https://maps.aerisapi.com/dm5iXYHKxhkIbBId8DzXP_kB3uMtbZhAt6dbf3tw4gW9CkPRb8Abzyfxb6eXXB/fqsf-accum/{z}/{x}/{y}/current.png"]
                case .cloudCover:
                    source.tiles = ["https://maps.aerisapi.com/dm5iXYHKxhkIbBId8DzXP_kB3uMtbZhAt6dbf3tw4gW9CkPRb8Abzyfxb6eXXB/satellite-infrared-color/{z}/{x}/{y}/current.png"]
            }
            
            source.tileSize = Double(truncating: NSNumber(value: 256))
            var layer = RasterLayer(id: "weather-layer")
            layer.source = "weather-source"

            do {
                try mapView.mapboxMap.style.addSource(source, id: "weather-source")
                try mapView.mapboxMap.style.addLayer(layer)
            } catch {
                print("Error adding weather layer: \(error)")
            }
        }

        func removeOverlay(from mapView: MapView) {
            do {
                try mapView.mapboxMap.style.removeLayer(withId: "weather-layer")
                try mapView.mapboxMap.style.removeSource(withId: "weather-source")
            } catch {
                print("Error removing weather layer: \(error)")
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
