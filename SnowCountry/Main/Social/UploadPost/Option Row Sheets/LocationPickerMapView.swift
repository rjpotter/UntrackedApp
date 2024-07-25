//
//  LocationPickerMapView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/25/24.
//


import SwiftUI
import MapKit

struct LocationPickerMapView: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var selectedLocationName: String

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: LocationPickerMapView

        init(parent: LocationPickerMapView) {
            self.parent = parent
        }

        @objc func didTapMap(gestureRecognizer: UIGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                let locationInView = gestureRecognizer.location(in: gestureRecognizer.view)
                if let mapView = gestureRecognizer.view as? MKMapView {
                    let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                    parent.selectedCoordinate = coordinate
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapMap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let coordinate = selectedCoordinate {
            uiView.removeAnnotations(uiView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            uiView.addAnnotation(annotation)
            updateMapRegion(uiView, coordinate: coordinate)
        }
    }

    private func updateMapRegion(_ mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
}
