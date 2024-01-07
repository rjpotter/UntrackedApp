//
//  TrackPageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/1/23.
//

import SwiftUI
import CoreLocation
import MapKit
import UniformTypeIdentifiers

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
    @State private var importConfirmationMessage: String?
    @State private var showToast = false
    @State private var alertMessage = ""

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
                    allowedContentTypes: [.json, .gpx],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let selectedFile = urls.first else {
                            importConfirmationMessage = "No file selected"
                            return
                        }

                        // Start accessing the security-scoped resource
                        let startAccessing = selectedFile.startAccessingSecurityScopedResource()

                        // Ensure we stop accessing the resource at the end of this block
                        defer { selectedFile.stopAccessingSecurityScopedResource() }

                        if startAccessing {
                            do {
                                let fileManager = FileManager.default
                                let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let destinationURL = documentDirectory.appendingPathComponent(selectedFile.lastPathComponent)

                                if fileManager.fileExists(atPath: destinationURL.path) {
                                    try fileManager.removeItem(at: destinationURL) // Remove existing file if needed
                                }
                                try fileManager.copyItem(at: selectedFile, to: destinationURL)
                                
                                let data = try Data(contentsOf: selectedFile)
                                // Process the file based on its type (JSON or GPX)
                                if selectedFile.pathExtension == "json" {
                                    // Handle JSON
                                    let decodedData = try JSONDecoder().decode(TrackData.self, from: data)
                                    trackData = decodedData
                                    locations = decodedData.locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
                                } else if selectedFile.pathExtension == "gpx" {
                                    // Handle GPX
                                    let gpxString = String(data: data, encoding: .utf8) ?? ""
                                    locations = GPXParser.parseGPX(gpxString)
                                }
                                alertMessage = "Imported \(selectedFile.lastPathComponent)"
                                showToast = true
                            } catch {
                                // Handle errors
                                print("Error copying file: \(error)")
                                alertMessage = "Error copying file: \(error.localizedDescription)"
                                showToast = true
                            }
                        } else {
                            // Handle the case where access couldn't be obtained
                            alertMessage = "Access to the file was denied."
                            showToast = true
                        }

                    case .failure(let error):
                        // Handle the failure case
                        print("Error during file import: \(error.localizedDescription)")
                        alertMessage = "Failed to import: \(error.localizedDescription)"
                        showToast = true
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
            
            if showToast {
                ToastView(text: alertMessage)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Auto-dismiss after 2 seconds
                            showToast = false
                        }
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: 50) // Position the toast at the top
            }
        }
    }
    
    private func selectTrack(_ fileName: String) {
        self.selectedTrackName = fileName
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
    
    func extractTrackNameFromGPX(_ gpxString: String) -> String? {
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

extension UTType {
    static var gpx: UTType {
        UTType(exportedAs: "public.gpx")
    }
}

struct ToastView: View {
    var text: String

    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
    }
}
