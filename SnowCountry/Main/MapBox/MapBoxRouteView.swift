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
    @State private var isRouteMenuVisible = false
    @State private var isRadarVisible = false
    @State private var isCloudsVisible = false
    @State private var isFutureSnowfallVisible = false
    @State private var isCurrentSnowDepthVisible = false
    @State private var showWeatherLayers = false
    private let buttonSize: CGFloat = 45
    private let iconSize: CGFloat = 30
    private let activeColor = Color.orange
    private let inactiveColor = Color.blue
    private let backgroundColor = Color("Background").opacity(0.5)

    var body: some View {
        NavigationView {
            ZStack {
                MapboxView(mapView: $mapView, isRadarOverlayVisible: $isRadarVisible, isSnowDepthOverlayVisible: $isCurrentSnowDepthVisible, isSnowForecastOverlayVisible: $isFutureSnowfallVisible, isCloudCoverOverlayVisible: $isCloudsVisible)
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

                VStack {
                    Spacer()
                    routePlanningButtons
                }
                .padding(.horizontal)
                .padding(.bottom, 40)

                if showingRouteNamingSheet {
                    SaveOverlay()
                }
            }
            .background(backgroundColor)
            .sheet(isPresented: $showWeatherLayers) {
                WeatherLayersView(isRadarVisible: $isRadarVisible, isCloudsVisible: $isCloudsVisible, isFutureSnowfallVisible: $isFutureSnowfallVisible, isCurrentSnowDepthVisible: $isCurrentSnowDepthVisible)
            }
        }
    }

    // Route Planning Buttons
    private var routePlanningButtons: some View {
        HStack(spacing: 20) {
            weatherLayerButton
            Spacer()
            if routeLogic.isRoutePlanningActive {
                routeControlButtons
            } else {
                routeCreationButton
            }
        }
    }

    // Individual Buttons
    private var weatherLayerButton: some View {
        CircleButton(
            systemImage: "line.3.horizontal.circle.fill",
            size: buttonSize,
            iconSize: iconSize,
            backgroundColor: activeColor,
            foregroundColor: .white,
            action: { showWeatherLayers.toggle() }
        )
    }

    private var routeCreationButton: some View {
        CircleButton(
            systemImage: "plus.circle",
            size: buttonSize,
            iconSize: iconSize,
            backgroundColor: routeLogic.isRoutePlanningActive ? activeColor : inactiveColor,
            foregroundColor: .white,
            action: { routeLogic.toggleRouteCreationMode() }
        )
    }

    private var routeControlButtons: some View {
        VStack(spacing: 15) {
            routeActionButton("pin.circle.fill", "Drop Point", routeLogic.addPointToRoute)
            routeActionButton("arrow.uturn.backward.circle.fill", "Undo", routeLogic.undoLastPoint)
            routeActionButton("flag.checkered.circle.fill", "Finish", {
                routeLogic.toggleRouteCreationMode()
                showingRouteNamingSheet = true
            })
        }
    }

    private func routeActionButton(_ systemName: String, _ label: String, _ action: @escaping () -> Void) -> some View {
        VStack {
            CircleButton(
                systemImage: systemName,
                size: buttonSize,
                iconSize: iconSize,
                backgroundColor: activeColor,
                foregroundColor: .white,
                action: action
            )
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
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

struct CircleButton: View {
    var systemImage: String
    var size: CGFloat
    var iconSize: CGFloat
    var backgroundColor: Color
    var foregroundColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .frame(width: size, height: size)
    }
}


extension Double {
    var radians: Double { return self * .pi / 180 }
}
