//
//  TrackToImageViewModel.swift
//  SnowCountry
//  Created by Ryan Potter on 3/06/24.
//

import UIKit
import MapKit
import Photos
import SwiftUI

class TrackToImageViewModel {
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
    
    static func generateMapSnapshot(track: MKPolyline, mapType: MKMapType, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = MKMapSnapshotter.Options()
        
        var region = MKCoordinateRegion(track.boundingMapRect)
        
        let paddingFactor: Double = 1.2
        region.span.latitudeDelta *= paddingFactor
        region.span.longitudeDelta *= paddingFactor
        
        let maxSpan = max(region.span.latitudeDelta, region.span.longitudeDelta)
        region.span = MKCoordinateSpan(latitudeDelta: maxSpan, longitudeDelta: maxSpan)
        
        let squareSize = CGSize(width: size.width, height: size.width)
        
        options.region = region
        options.scale = UIScreen.main.scale
        options.size = squareSize
        options.mapType = mapType
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                print("Snapshot error: \(error?.localizedDescription ?? "unknown error")")
                completion(nil)
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(options.size, true, options.scale)
            snapshot.image.draw(at: .zero)
            
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(5.0)
            context?.setStrokeColor(UIColor.orange.cgColor)
            
            let path = UIBezierPath()
            var firstPoint = true
            
            for i in 0..<track.pointCount {
                let point = track.points()[i]
                let coord = point.coordinate
                let pointInSnapshot = snapshot.point(for: coord)
                
                if firstPoint {
                    path.move(to: pointInSnapshot)
                    firstPoint = false
                } else {
                    path.addLine(to: pointInSnapshot)
                }
            }
            
            path.stroke()
            let mapImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            print("Map snapshot generated successfully.")
            saveDebugImage(image: mapImage, name: "MapSnapshot")
            completion(mapImage)
        }
    }
    
    static func overlayStatsOnImage(mapImage: UIImage, username: String, maxSpeed: Double, totalDescent: Double, maxElevation: Double, totalDescentDistance: Double, trackDate: String, mapStyle: MapStyle) -> UIImage? {
        let size = mapImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        mapImage.draw(at: .zero)
        
        let textColor = UIColor.white
        let customFont = UIFont(name: "Good Times", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
        let textFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let smallTextFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let customAttributes: [NSAttributedString.Key: Any] = [
            .font: customFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let smallAttributes: [NSAttributedString.Key: Any] = [
            .font: smallTextFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let untrackedText = "UNTRACKED"
        let untrackedRect = CGRect(x: 10, y: 10, width: size.width, height: 25)
        untrackedText.draw(in: untrackedRect, withAttributes: customAttributes)
        
        let usernameRect = CGRect(x: 10, y: 40, width: size.width, height: 20)
        username.draw(in: usernameRect, withAttributes: smallAttributes)
        
        let dateText = trackDate
        let dateRect = CGRect(x: 10, y: 65, width: size.width, height: 20)
        dateText.draw(in: dateRect, withAttributes: smallAttributes)
        
        let iconSize: CGFloat = 20
        let leftPadding: CGFloat = 10
        let rightPadding: CGFloat = 10
        let statSpacing: CGFloat = 30
        
        if let speedIcon = UIImage(systemName: "gauge")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            speedIcon.draw(in: CGRect(x: leftPadding, y: size.height - 80, width: iconSize, height: iconSize))
        }
        let maxSpeedText = String(format: "%.1f mph", maxSpeed)
        let maxSpeedRect = CGRect(x: leftPadding + iconSize + 10, y: size.height - 80, width: size.width / 2 - leftPadding - iconSize - 10, height: 25)
        maxSpeedText.draw(in: maxSpeedRect, withAttributes: attributes)
        
        if let verticalIcon = UIImage(systemName: "arrow.down")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            verticalIcon.draw(in: CGRect(x: leftPadding, y: size.height - 50, width: iconSize, height: iconSize))
        }
        let totalDescentText = String(format: "%.1f ft", totalDescent)
        let totalDescentRect = CGRect(x: leftPadding + iconSize + 10, y: size.height - 50, width: size.width / 2 - leftPadding - iconSize - 10, height: 25)
        totalDescentText.draw(in: totalDescentRect, withAttributes: attributes)
        
        if let elevationIcon = UIImage(systemName: "arrow.up.to.line")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            elevationIcon.draw(in: CGRect(x: size.width - rightPadding - iconSize - statSpacing - 80, y: size.height - 80, width: iconSize, height: iconSize))
        }
        let maxElevationText = String(format: "%.1f ft", maxElevation)
        let maxElevationRect = CGRect(x: size.width - rightPadding - 100, y: size.height - 80, width: 100, height: 25)
        maxElevationText.draw(in: maxElevationRect, withAttributes: attributes)
        
        if let distanceIcon = UIImage(systemName: "arrow.down.right")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            distanceIcon.draw(in: CGRect(x: size.width - rightPadding - iconSize - statSpacing - 80, y: size.height - 50, width: iconSize, height: iconSize))
        }
        let totalDescentDistanceText = String(format: "%.1f mi", totalDescentDistance)
        let totalDescentDistanceRect = CGRect(x: size.width - rightPadding - 100, y: size.height - 50, width: 100, height: 25)
        totalDescentDistanceText.draw(in: totalDescentDistanceRect, withAttributes: attributes)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if finalImage != nil {
            print("Stats overlay added successfully.")
        } else {
            print("Failed to add stats overlay.")
        }
        
        saveDebugImage(image: finalImage, name: "FinalImage")
        
        return finalImage
    }
    
    static func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            if success {
                print("Successfully saved image to photo library")
            } else if let error = error {
                print("Error saving image to photo library: \(error)")
            }
        })
    }
    
    static func generateAndSaveImage(track: MKPolyline, mapType: MKMapType, username: String, maxSpeed: Double, totalDescent: Double, maxElevation: Double, totalDescentDistance: Double, trackDate: String, mapStyle: MapStyle, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        generateMapSnapshot(track: track, mapType: mapType, size: size) { mapImage in
            guard let mapImage = mapImage else {
                print("Failed to generate map snapshot.")
                completion(nil)
                return
            }
            
            let finalImage = overlayStatsOnImage(
                mapImage: mapImage,
                username: username,
                maxSpeed: maxSpeed,
                totalDescent: totalDescent,
                maxElevation: maxElevation,
                totalDescentDistance: totalDescentDistance,
                trackDate: trackDate,
                mapStyle: mapStyle
            )
            
            if let finalImage = finalImage {
                saveImageToPhotoLibrary(finalImage)
                completion(finalImage)
            } else {
                print("Failed to overlay stats on image.")
                completion(nil)
            }
        }
    }

    static func saveDebugImage(image: UIImage?, name: String) {
        guard let image = image else { return }
        if let data = image.pngData() {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirectory.appendingPathComponent("\(name).png")
            try? data.write(to: url)
            print("Saved debug image at \(url)")
        }
    }
}

struct GenerateImageButton: UIViewControllerRepresentable {
    var track: MKPolyline
    var username: String
    var maxSpeed: Double
    var totalDescent: Double
    var maxElevation: Double
    var totalDescentDistance: Double
    var trackDate: String
    var mapType: MKMapType
    var mapStyle: MapStyle
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    static func generateImage(track: MKPolyline, username: String, maxSpeed: Double, totalDescent: Double, maxElevation: Double, totalDescentDistance: Double, trackDate: String, mapType: MKMapType, mapStyle: MapStyle, completion: @escaping (UIImage?) -> Void) {
        let imageSize = CGSize(width: 375, height: 667)
        TrackToImageViewModel.generateAndSaveImage(
            track: track,
            mapType: mapType,
            username: username,
            maxSpeed: maxSpeed,
            totalDescent: totalDescent,
            maxElevation: maxElevation,
            totalDescentDistance: totalDescentDistance,
            trackDate: trackDate,
            mapStyle: mapStyle,
            size: imageSize,
            completion: completion
        )
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        GenerateImageButton.generateImage(
            track: track,
            username: username,
            maxSpeed: maxSpeed,
            totalDescent: totalDescent,
            maxElevation: maxElevation,
            totalDescentDistance: totalDescentDistance,
            trackDate: trackDate,
            mapType: mapType,
            mapStyle: mapStyle,
            completion: { _ in }
        )
    }
}

struct Renderer {
    static func renderViewToImage<V: View>(view: V, size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = UIColor.clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
    }
}
