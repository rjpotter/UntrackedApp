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
    @State private var showingRouteNamingAlert = false
    @State private var newRouteName = ""
    @State private var newRouteColor = UIColor.blue
    @State private var routeMenu = false
    @State private var mapView: MapView?

    var body: some View {
        VStack {
            Text("SnowCountry")
                .font(Font.custom("Good Times", size:30))
            ZStack {
                // Map View
                MapboxView(userLocationProvider: routeLogic.userLocationProvider, mapView: $mapView)
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
                        
                        Button(action: {
                                routeLogic.toggleRouteCreationMode()
                                routeMenu.toggle()
                        }) {
                            Image(systemName: routeMenu ? "minus.circle" : "plus.circle")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .padding(5)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        // Button to Add Point to Route
                        if routeLogic.isRoutePlanningActive {
                            Button(action: { routeLogic.addPointToRoute() }) {
                                Image(systemName: "pin.circle.fill")
                                    .font(.system(size: 55))
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.cyan, .orange)
                                    .shadow(radius: 5)
                                    .padding(5)
                            }
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 40)
                }
                
                // UI for Naming and Saving the Route
                if showingRouteNamingAlert {
                    VStack {
                        TextField("Route Name", text: $newRouteName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding()
                        
                        Button("Save Route") {
                            routeLogic.completeRoute(with: newRouteName, color: newRouteColor)
                            showingRouteNamingAlert = false
                            newRouteName = ""
                        }
                        .padding()
                        .background(newRouteName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(newRouteName.isEmpty)
                    }
                    .frame(width: 300, height: 200)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }
            .onChange(of: routeLogic.isRoutePlanningActive) { _ in
                if !routeLogic.isRoutePlanningActive && !routeLogic.routePoints.isEmpty {
                    showingRouteNamingAlert = true
                }
            }
        }
        .background(Color("Background").opacity(0.5))
    }
}
