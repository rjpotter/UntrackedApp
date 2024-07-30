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
    @ObservedObject var socialViewModel: SocialViewModel
    @State private var selectedTrackURL: URL?
    @State private var selectedTrackName: String = ""
    @State private var selectedTrackDate: String = ""
    @State private var navigateToTrackToImageView: Bool = false
    var fromSocialPage: Bool
    @State private var trackData: TrackData?
    @State private var locations: [CLLocation] = []
    @ObservedObject var locationManager: LocationManager
    @State private var showDeleteConfirmation = false
    @State private var fileToDelete: String?
    @State private var trackSelection: TrackSelection?
    @State private var showingShareSheet = false
    @State private var fileToShare: ShareableFile?
    @Binding var isMetric: Bool
    @Binding var navigateBackToRoot: Bool // Add this binding
    @State private var importing = false
    @State private var importConfirmationMessage: String?
    @State private var showToast = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Header
                    HStack {
                        Button(action: {
                            if fromSocialPage {
                                navigateBackToRoot = true // Use the binding to navigate back to the root
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "arrowshape.backward")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        if fromSocialPage {
                            Text("Select Track")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        } else {
                            Text("Track History")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        Button(action: { importing = true }) {
                            Image(systemName: "square.and.arrow.down")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding()
                    
                    // List of Tracks
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(locationManager.getTrackFiles().sorted(by: {
                                (dateTime(from: $0) ?? Date.distantFuture) > (dateTime(from: $1) ?? Date.distantFuture)
                            }), id: \.self) { fileName in
                                TrackCard(fileName: fileName, trackName: getTrackName(from: fileName), action: { selectTrack(fileName) })
                                    .contextMenu {
                                        Button(action: { exportTrackFile(named: fileName) }) {
                                            Label("Export", systemImage: "square.and.arrow.up")
                                        }
                                        Button(role: .destructive, action: { fileToDelete = fileName; showDeleteConfirmation = true }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
                .fileImporter(
                    isPresented: $importing,
                    allowedContentTypes: [.json, .gpx],
                    allowsMultipleSelection: true
                ) { result in
                    handleFileImport(result: result)
                }
            }
            .background(Color("Base"))
        }
        .sheet(item: $trackSelection) { selection in
            let filePath = locationManager.getDocumentsDirectory().appendingPathComponent(selection.trackFileName)
            StatView(trackFilePath: filePath, trackName: selection.trackName, trackDate: selection.trackDate)
        }
        .sheet(item: $fileToShare) {
            ActivityView(activityItems: [$0.url], applicationActivities: nil)
        }
        .fullScreenCover(isPresented: $navigateToTrackToImageView) {
            NavigationView {
                TrackToImageView(trackURL: selectedTrackURL ?? URL(string: "defaultURL")!, trackName: selectedTrackName, user: socialViewModel.user, socialViewModel: socialViewModel, navigateBackToRoot: $navigateBackToRoot)
                    .navigationBarTitle("Select Photo", displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        navigateToTrackToImageView = false
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    })
            }
        }

        if showDeleteConfirmation {
            ConfirmationDeleteOverlay()
        }

        if showToast {
            ToastView(text: alertMessage)
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showToast = false
                    }
                }
                .position(x: UIScreen.main.bounds.width / 2, y: 50)
        }
    }
    
    private func selectTrack(_ fileName: String) {
        let trackURL = locationManager.getDocumentsDirectory().appendingPathComponent(fileName)
        let trackName = getTrackName(from: fileName)
        let trackDate = formatTrackDate(from: fileName) // Implement this method to format the date

        // Now, you have trackURL (already unwrapped), trackName, and trackDate ready to be used.
        // Assuming TrackToImageView can handle these parameters, and trackURL can be nil:

        if fromSocialPage {
            // Prepare the necessary data to navigate to TrackToImageView
            // Ensure selectedTrackURL, selectedTrackName, and selectedTrackDate are @State variables updated here
            let trackDate = formatTrackDate(from: fileName) ?? "Unknown Date"
            selectedTrackURL = trackURL
            selectedTrackName = trackName
            selectedTrackDate = trackDate
            navigateToTrackToImageView = true
        } else {
            // Existing logic for non-social page navigation
            self.trackSelection = TrackSelection(trackName: trackName, trackFileName: fileName, trackDate: trackDate!, isStatViewPresented: true)
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for selectedFile in urls {
                let startAccessing = selectedFile.startAccessingSecurityScopedResource()
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                
                if startAccessing {
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = documentDirectory.appendingPathComponent(selectedFile.lastPathComponent)
                        
                        if fileManager.fileExists(atPath: destinationURL.path) {
                            try fileManager.removeItem(at: destinationURL)
                        }
                        try fileManager.copyItem(at: selectedFile, to: destinationURL)
                        
                        let data = try Data(contentsOf: selectedFile)
                        if selectedFile.pathExtension == "json" {
                            let decodedData = try JSONDecoder().decode(TrackData.self, from: data)
                            trackData = decodedData
                            locations = decodedData.locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
                        } else if selectedFile.pathExtension == "gpx" {
                            let gpxString = String(data: data, encoding: .utf8) ?? ""
                            locations = GPXParser.parseGPX(gpxString)
                        }
                        alertMessage = "Imported \(selectedFile.lastPathComponent)"
                        showToast = true
                    } catch {
                        print("Error copying file: \(error)")
                        alertMessage = "Error copying file: \(error.localizedDescription)"
                        showToast = true
                    }
                } else {
                    alertMessage = "Access to the file was denied."
                    showToast = true
                }
            }
        case .failure(let error):
            print("Error during file import: \(error.localizedDescription)")
            alertMessage = "Failed to import: \(error.localizedDescription)"
            showToast = true
        }
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
    
    // Helper function to parse the date and time from the file name
    func dateTime(from fileName: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Consistent locale for parsing

        // Formats: "SnowCountry-Track-MM-dd-yyyy" or "Untracked-Track-MM-dd-yyyy"
        let prefixes = ["SnowCountry-Track-", "Untracked-Track-"]
        dateFormatter.dateFormat = "MM-dd-yyyy"
        for prefix in prefixes {
            if let dateStartIndex = fileName.range(of: prefix)?.upperBound {
                let dateStringStart = fileName[dateStartIndex...]
                if let endIndex = dateStringStart.firstIndex(where: { !$0.isNumber && $0 != "-" }) {
                    let dateString = String(dateStringStart[..<endIndex])
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                } else if let date = dateFormatter.date(from: String(dateStringStart)) {
                    // In case the date is at the end of the filename
                    return date
                }
            }
        }

        // Second format: "yyyy-MM-dd-min-hr-sec"
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        if let dotIndex = fileName.lastIndex(of: "."), dotIndex > fileName.startIndex {
            let dateString = String(fileName[..<dotIndex])
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }

        // If none of the formats matched, return a distant past date
        return Date.distantPast
    }
    
    func formatTrackDate(from fileName: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Consistent locale for parsing
        
        // Formats: "SnowCountry-Track-MM-dd-yyyy" or "Untracked-Track-MM-dd-yyyy"
        let prefixes = ["SnowCountry-Track-", "Untracked-Track-"]
        dateFormatter.dateFormat = "MM-dd-yyyy"
        for prefix in prefixes {
            if let dateStartIndex = fileName.range(of: prefix)?.upperBound {
                let dateStringStart = fileName[dateStartIndex...]
                if let endIndex = dateStringStart.firstIndex(where: { !$0.isNumber && $0 != "-" }) {
                    let dateString = String(dateStringStart[..<endIndex])
                    if let date = dateFormatter.date(from: dateString) {
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        return dateFormatter.string(from: date)
                    }
                } else if let date = dateFormatter.date(from: String(dateStringStart)) {
                    // In case the date is at the end of the filename
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    return dateFormatter.string(from: date)
                }
            }
        }
        
        // Second format: "yyyy-MM-dd-min-hr-sec"
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        if let dotIndex = fileName.lastIndex(of: "."), dotIndex > fileName.startIndex {
            let dateString = String(fileName[..<dotIndex])
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: date)
            }
        }
        
        // If none of the formats matched or parsing failed
        return "Unknown Date"
    }

    
    struct ActivityView: UIViewControllerRepresentable {
        let activityItems: [Any]
        let applicationActivities: [UIActivity]?

        func makeUIViewController(context: Context) -> UIActivityViewController {
            return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        }
    }
}

extension UTType {
    static var gpx: UTType {
        UTType(exportedAs: "public.gpx")
    }
}

struct TrackCard: View {
    var fileName: String
    var trackName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(trackName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Filename: \(fileName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "eye.fill")
                    .foregroundColor(.orange)
            }
            .padding()
            .background(Color.secondary.opacity(0.3))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle()) // This ensures the button style doesn't interfere with the card's appearance
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

struct TrackSelection: Identifiable {
    let id = UUID()  // Unique identifier
    var trackName: String
    var trackFileName: String
    var trackDate: String
    var isStatViewPresented: Bool
}
