//
//  TrackPageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/1/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct ShareableFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct TrackHistoryListView: View {
    @State private var trackData: TrackData?
    @State private var locations: [CLLocation] = []
    @ObservedObject var locationManager: LocationManager
    @State private var showDeleteConfirmation = false
    @State private var fileToDelete: String?
    @State private var showingStatView = false
    @State private var selectedTrackName: String?
    @State private var showingShareSheet = false
    @State private var fileToShare: ShareableFile?
    @Binding var isMetric: Bool
    @State private var importing = false


    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        importing = true
                    } label: {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                    .tint(.blue)
                    Spacer()

                    Text("Track History")
                        .foregroundColor(.gray)
                    Spacer()
                }

                List {
                    ForEach(locationManager.getTrackFiles().sorted(by: { $0 > $1 }), id: \.self) { fileName in
                        let trackName = getTrackName(from: fileName)
                        Button("View \(trackName)") {
                            selectTrack(fileName)
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .swipeActions(edge: .leading) {
                            Button {
                                exportTrackFile(named: fileName)
                            } label: {
                                Label("Export", systemImage: "square.and.arrow.up")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                fileToDelete = fileName
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .fileImporter(
                    isPresented: $importing,
                    allowedContentTypes: [.json],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        guard let selectedFile: URL = try result.get().first else { return }
                        let data = try Data(contentsOf: selectedFile)
                        let decodedData = try JSONDecoder().decode(TrackData.self, from: data)
                        trackData = decodedData
                        locations = decodedData.locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
                    } catch {
                        // Handle failure.
                        print("Error importing .json file: \(error)")
                    }
                }
            }
            // Sheet for StatView
            .sheet(isPresented: $showingStatView) {
                if let selectedTrackName = selectedTrackName {
                    let filePath = locationManager.getDocumentsDirectory().appendingPathComponent(selectedTrackName)
                    StatView(trackFilePath: filePath, isMetric: $isMetric)
                } else {
                    Text("No track selected")
                }
            }

            // Sheet for ActivityView
            .sheet(item: $fileToShare) { shareableFile in
                ActivityView(activityItems: [shareableFile.url], applicationActivities: nil)
            }

            if showDeleteConfirmation {
                ConfirmationDeleteOverlay()
            }
        }
    }
    
    private func selectTrack(_ fileName: String) {
        self.selectedTrackName = fileName
        print("Selected track file path: \(locationManager.getDocumentsDirectory().appendingPathComponent(fileName))")
        self.showingStatView = true
    }
    
    func ConfirmationDeleteOverlay() -> some View {
        Color.black.opacity(0.7)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Text("Are you sure you want to delete recording?")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    
                    HStack(spacing: 20) {
                        Button("Delete") {
                            if let fileToDelete = fileToDelete {
                                locationManager.deleteTrackFile(named: fileToDelete)
                                self.fileToDelete = nil
                            }
                            showDeleteConfirmation = false
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Cancel") {
                            showDeleteConfirmation = false
                        }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.8))
                .cornerRadius(20)
            )
    }
    
    func getTrackName(from fileName: String) -> String {
        let filePath = locationManager.getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            if fileName.hasSuffix(".json") {
                // Handle JSON file
                let jsonData = try Data(contentsOf: filePath)
                let trackData = try JSONDecoder().decode(TrackData.self, from: jsonData)
                return trackData.trackName ?? fileName
            } else if fileName.hasSuffix(".gpx") {
                // Handle GPX file
                let gpxData = try Data(contentsOf: filePath)
                let gpxString = String(data: gpxData, encoding: .utf8) ?? ""
                return extractTrackNameFromGPX(gpxString) ?? fileName
            }
        } catch {
            print("Error reading file \(fileName): \(error)")
        }
        return fileName
    }
    
    private func exportTrackFile(named fileName: String) {
        print("Attempting to export file: \(fileName)")
        let fileURL = locationManager.getDocumentsDirectory().appendingPathComponent(fileName)
        print("Generated file URL: \(fileURL)")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("File exists, proceeding to share.")
            self.fileToShare = ShareableFile(url: fileURL)
        } else {
            print("File does not exist at path: \(fileURL.path)")
        }
    }
    
    private func extractTrackNameFromGPX(_ gpxString: String) -> String? {
        // Simple XML parsing to extract the track name
        // Note: This is a basic implementation. For complex GPX files, consider using an XML parser library.
        if let range = gpxString.range(of: "<name>", options: .caseInsensitive),
           let endRange = gpxString.range(of: "</name>", options: .caseInsensitive, range: range.upperBound..<gpxString.endIndex) {
            return String(gpxString[range.upperBound..<endRange.lowerBound])
        }
        return nil
    }
    
    struct ActivityView: UIViewControllerRepresentable {
        let activityItems: [Any]
        let applicationActivities: [UIActivity]?

        func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
            return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
    }
}
