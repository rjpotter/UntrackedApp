//
//  MapBoxRouteView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/8/23.
//

import SwiftUI
import MapboxMaps
import CoreLocation

struct MapBoxRouteView: View {
    @StateObject var routeLogic = MapBoxRouteLogic()
    @State private var newRouteName = ""
    @State private var showingRouteNamingSheet = false
    @State private var mapView: MapView?
    @State private var showingRouteDetails = false
    @State private var selectedRoute: CustomRoute? = nil
    @State private var isRouteMenuVisible = false // Flag to show/hide route menu

    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                MapboxView(mapView: $mapView)
                    .edgesIgnoringSafeArea(.top)
                    .onAppear {
                        if let mapView = mapView {
                            routeLogic.setMapView(mapView)
                        }
                    }

                // Stationary Cursor for Dropping Points
                if routeLogic.isRoutePlanningActive {
                    Image(systemName: "dot.viewfinder")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.orange, .cyan)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.system(size: 30))
                }

                // Route Planning UI
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        // Toggle route creation mode, add points, and undo button
                        Button(action: { routeLogic.toggleRouteCreationMode() }) {
                            VStack {
                                Image(systemName: routeLogic.isRoutePlanningActive ? "minus.circle" : "plus.circle")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .padding(5)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                                Text("") // Placeholder text for alignment
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                        }

                        if routeLogic.isRoutePlanningActive {
                            Button(action: { routeLogic.addPointToRoute() }) {
                                VStack {
                                    Image(systemName: "pin.circle.fill")
                                        .font(.system(size: 55))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.cyan, .orange)
                                        .shadow(radius: 5)
                                    Text("Drop Point")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                                .padding(5)
                            }

                            Button(action: { routeLogic.undoLastPoint() }) {
                                VStack {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .font(.system(size: 55))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.cyan, .orange)
                                    Text("Undo")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                                .padding(5)
                            }

                            Button(action: {
                                routeLogic.toggleRouteCreationMode() // End route creation mode
                                showingRouteNamingSheet = true       // Show the naming overlay
                            }) {
                                VStack {
                                    Image(systemName: "flag.checkered.circle.fill")
                                        .font(.system(size: 55))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.cyan, .orange)
                                    Text("Finish")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                                .padding(5)
                            }
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 40)
                }
                if showingRouteNamingSheet {
                    SaveOverlay()
                }
            }
        }
        .background(Color("Background").opacity(0.5))
    }
    
    // Save Overlay View
    private func SaveOverlay() -> some View {
        VStack {
            Spacer()
            VStack {
                Text("Name Your Track")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()

                TextField("Enter Track Name", text: $newRouteName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack(spacing: 20) {
                    Button("Save") {
                        routeLogic.completeRoute(with: newRouteName, color: UIColor.blue)
                        showingRouteNamingSheet = false
                        newRouteName = ""
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        showingRouteNamingSheet = false
                    }
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Spacer()
            }
            .background(Color("Background").opacity(0.5))
            .padding(.top, 20)
            .padding(.bottom, 25)
            Spacer()
        }
    }
}


extension Double {
    var radians: Double { return self * .pi / 180 }
}
