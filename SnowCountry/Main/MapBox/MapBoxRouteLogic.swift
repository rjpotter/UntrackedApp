import SwiftUI
import MapboxMaps
import CoreLocation

// Custom Route Data Model
struct CustomRoute {
    var id = UUID()
    var name: String
    var color: UIColor
    var points: [CLLocationCoordinate2D]
    // Additional properties for elevation data, etc.
}

class MapBoxRouteLogic: ObservableObject {
    @Published var userLocationProvider = UserLocationProvider()
    @Published var isRoutePlanningActive: Bool = false
    @Published var routePoints: [CLLocationCoordinate2D] = []
    @Published var routes: [CustomRoute] = []
    @Published var selectedRoute: CustomRoute?
    @Published var mapView: MapView?
    
    // Toggles route creation mode
    func toggleRouteCreationMode() {
        isRoutePlanningActive.toggle()
        if !isRoutePlanningActive {
            drawFinalRouteLine()
        }
    }

    // Adds a point to the current route
    func addPointToRoute() {
        guard let mapView = mapView, isRoutePlanningActive else { return }
        let centerCoordinate = mapView.cameraState.center
        routePoints.append(centerCoordinate)
        drawTemporaryRouteLine()
    }

    private func drawTemporaryRouteLine() {
        guard let mapView = mapView, !routePoints.isEmpty else { return }

        let lineId = "temporaryLine"

        // Remove existing line if it exists
        if let _ = try? mapView.mapboxMap.style.layer(withId: lineId) {
            try? mapView.mapboxMap.style.removeLayer(withId: lineId)
            try? mapView.mapboxMap.style.removeSource(withId: lineId)
        }

        // Add new line
        let lineString = LineString(routePoints)
        var source = GeoJSONSource()
        source.data = .feature(Feature(geometry: Geometry.lineString(lineString)))
        try? mapView.mapboxMap.style.addSource(source, id: lineId)

        var layer = LineLayer(id: lineId)
        layer.source = lineId
        layer.lineColor = .constant(StyleColor(UIColor.blue))
        layer.lineWidth = .constant(5)

        try? mapView.mapboxMap.style.addLayer(layer)
    }

    // Completes and saves the current route
    func completeRoute(with name: String, color: UIColor) {
        let newRoute = CustomRoute(name: name, color: color, points: routePoints)
        routes.append(newRoute)
        routePoints = []
        isRoutePlanningActive = false
    }

    private func drawFinalRouteLine() {
        guard let mapView = mapView, !routePoints.isEmpty else { return }

        let routeLineId = "routeLine-\(UUID().uuidString)"
        let lineString = LineString(routePoints)

        var source = GeoJSONSource()
        source.data = .feature(Feature(geometry: Geometry.lineString(lineString)))

        try? mapView.mapboxMap.style.addSource(source, id: routeLineId)

        var layer = LineLayer(id: routeLineId)
        layer.source = routeLineId
        layer.lineColor = .constant(StyleColor(UIColor.blue))
        layer.lineWidth = .constant(5)

        try? mapView.mapboxMap.style.addLayer(layer)
    }

    // Link the MapView from the SwiftUI view
    func setMapView(_ mapView: MapView) {
        self.mapView = mapView
    }
    
    func setMapView(_ mapView: MapView?) {
            self.mapView = mapView
        }
}
