import SwiftUI
import MapboxMaps
import CoreLocation

// Custom Route Data Model
struct CustomRoute: Identifiable {
    var id = UUID()
    var name: String
    var color: UIColor
    var points: [CLLocationCoordinate2D]
    var totalElevationGain: Double
    var totalElevationLoss: Double
    var distance: Double
    var steepestGrade: Double
    // Additional properties for elevation data, etc.
}

class MapBoxRouteLogic: ObservableObject {
    @Published var userLocationProvider = UserLocationProvider()
    @Published var isRoutePlanningActive: Bool = false
    @Published var routePoints: [CLLocationCoordinate2D] = []
    @Published var routes: [CustomRoute] = []
    @Published var selectedRoute: CustomRoute?
    @Published var mapView: MapView?
    @Published var showAlert: Bool = false
    
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

    func completeRoute(with name: String, color: UIColor) {
        let elevationPoints = convertToElevationPoints(routePoints)
        let totalElevationGain = calculateTotalElevationGain(elevationPoints)
        let totalElevationLoss = calculateTotalElevationLoss(elevationPoints)
        let distance = calculateDistance(elevationPoints)
        let steepestGrade = calculateSteepestGrade(elevationPoints)

        let newRoute = CustomRoute(name: name, color: color, points: routePoints,
                                   totalElevationGain: totalElevationGain,
                                   totalElevationLoss: totalElevationLoss,
                                   distance: distance,
                                   steepestGrade: steepestGrade)
        routes.append(newRoute)
        routePoints = []
        isRoutePlanningActive = false
        showAlert = true // Show alert on successful save
    }
    
    func convertToElevationPoints(_ coordinates: [CLLocationCoordinate2D]) -> [ElevationPoint] {
        // Replace this implementation with your method of fetching elevation data
        return coordinates.map { ElevationPoint(coordinate: $0, elevation: fetchElevation(for: $0)) }
    }

    func fetchElevation(for coordinate: CLLocationCoordinate2D) -> Double {
        // Fetch elevation data for the coordinate
        // This is a placeholder; implement according to your data source
        return 0.0
    }
    
    // Method to undo the last point
    func undoLastPoint() {
        guard isRoutePlanningActive, !routePoints.isEmpty else { return }
        
        routePoints.removeLast()
        drawTemporaryRouteLine() // Redraw the line without the last point
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
    
    func createOrUpdateRoute(name: String, color: UIColor, points: [CLLocationCoordinate2D]) {
        // Convert the CLLocationCoordinate2D array to an ElevationPoint array
        let elevationPoints = convertToElevationPoints(points)

        // Use the ElevationPoint array for calculations
        let totalElevationGain = calculateTotalElevationGain(elevationPoints)
        let totalElevationLoss = calculateTotalElevationLoss(elevationPoints)
        let distance = calculateDistance(elevationPoints)
        let steepestGrade = calculateSteepestGrade(elevationPoints)
        
        // Create the new route with the calculated statistics
        let route = CustomRoute(name: name, color: color, points: points,
                                totalElevationGain: totalElevationGain,
                                totalElevationLoss: totalElevationLoss,
                                distance: distance,
                                steepestGrade: steepestGrade)
        
        // Add the new route to your routes array
        routes.append(route)
    }

    // Link the MapView from the SwiftUI view
    func setMapView(_ mapView: MapView) {
        self.mapView = mapView
    }
    
    func setMapView(_ mapView: MapView?) {
            self.mapView = mapView
        }
    
    // Dummy struct to represent a point with elevation (replace with your actual data structure)
    struct ElevationPoint {
        var coordinate: CLLocationCoordinate2D
        var elevation: Double // Elevation in meters
    }

    // Assuming you have a method to get ElevationPoints including elevation data
    func getElevationPoints(from coordinates: [CLLocationCoordinate2D]) -> [ElevationPoint] {
        // Placeholder: convert CLLocationCoordinate2D to ElevationPoint
        // In a real scenario, fetch actual elevation data for each coordinate
        return coordinates.map { ElevationPoint(coordinate: $0, elevation: 0.0) }
    }

    func calculateTotalElevationGain(_ points: [ElevationPoint]) -> Double {
        var totalGain: Double = 0
        for i in 1..<points.count {
            let elevationChange = points[i].elevation - points[i - 1].elevation
            if elevationChange > 0 {
                totalGain += elevationChange
            }
        }
        return totalGain
    }

    func calculateTotalElevationLoss(_ points: [ElevationPoint]) -> Double {
        var totalLoss: Double = 0
        for i in 1..<points.count {
            let elevationChange = points[i].elevation - points[i - 1].elevation
            if elevationChange < 0 {
                totalLoss -= elevationChange
            }
        }
        return totalLoss
    }

    func calculateDistance(_ points: [ElevationPoint]) -> Double {
        var totalDistance: Double = 0
        for i in 1..<points.count {
            totalDistance += distanceBetween(points[i].coordinate, points[i - 1].coordinate)
        }
        return totalDistance
    }

    func calculateSteepestGrade(_ points: [ElevationPoint]) -> Double {
        var maxGrade: Double = 0
        for i in 1..<points.count {
            let distance = distanceBetween(points[i].coordinate, points[i - 1].coordinate)
            let elevationChange = points[i].elevation - points[i - 1].elevation
            let grade = (elevationChange / distance) * 100 // Grade in percentage
            if grade > maxGrade {
                maxGrade = grade
            }
        }
        return maxGrade
    }

    private func distanceBetween(_ point1: CLLocationCoordinate2D, _ point2: CLLocationCoordinate2D) -> Double {
        // Haversine formula or similar to calculate distance
        let lat1 = point1.latitude.radians
        let lon1 = point1.longitude.radians
        let lat2 = point2.latitude.radians
        let lon2 = point2.longitude.radians
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = 6371000 * c // Distance in meters (Earth's radius = 6371 km)
        return distance
    }
}
