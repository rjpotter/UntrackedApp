//
//  MapBoxRouteLogic.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/7/23.
//

import SwiftUI
import MapboxMaps

// Custom Route Data Model
struct CustomRoute {
    var name: String
    var color: UIColor
    var points: [CLLocationCoordinate2D]
    // Additional properties for slope, vertical distances, etc.
}

// Route Logic ViewModel
class MapBoxRouteLogic: ObservableObject {
    @Published var routePoints: [CLLocationCoordinate2D] = []
    @Published var isRoutePlanningActive: Bool = false
    @Published var selectedRoute: CustomRoute?
    @Published var currentLineColor: UIColor = .blue

    // Add a point to the current route
    func addPointToRoute(at coordinate: CLLocationCoordinate2D) {
        routePoints.append(coordinate)
        // Add logic to update the map view with a new line segment
    }

    // Complete and save the current route
    func completeRoute(with name: String) {
        let newRoute = CustomRoute(name: name, color: currentLineColor, points: routePoints)
        // Save the new route
        // Reset for a new route
        routePoints = []
        isRoutePlanningActive = false
        // Additional logic as needed
    }

    // Select and view details of a saved route
    func selectRoute(_ route: CustomRoute) {
        selectedRoute = route
        // Logic to highlight the selected route on the map
    }

    // Logic to handle other functionalities as described...
}

// SwiftUI View for Route Planning
struct MapBoxRouteView: View {
    @StateObject var routeLogic = MapBoxRouteLogic()

    var body: some View {
        ZStack {
            // Your Map View
            MapboxView() // Assuming this is your MapView implementation
                .gesture(DragGesture().onEnded { value in
                    if routeLogic.isRoutePlanningActive {
                        // Convert the drag location to map coordinates
                        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Use actual conversion logic
                        routeLogic.addPointToRoute(at: coordinate)
                    }
                })

            // Route Planning UI
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { routeLogic.isRoutePlanningActive.toggle() }) {
                        Image(systemName: "plus.circle")
                            .font(.largeTitle)
                            .padding()
                    }
                }
            }

            // Additional UI Components for naming, saving the route, etc.
        }
    }
}

// Implement additional SwiftUI views as needed for user inputs and interactions
