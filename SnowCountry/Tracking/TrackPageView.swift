//
//  TrackPageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 12/1/23.
//

import SwiftUI

struct TrackHistoryListView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var showDeleteConfirmation = false
    @State private var fileToDelete: String?
    
    var body: some View {
        ZStack {
            List {
                ForEach(locationManager.getTrackFiles().sorted(by: { $0 > $1 }), id: \.self) { fileName in
                    Button("View \(fileName)") {
                        // Your action to view the track
                    }
                    .padding()
                    .foregroundColor(.black)
                    .background(Color.gray)
                    .cornerRadius(10)
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
        }
        if showDeleteConfirmation {
            ConfirmationDeleteOverlay()
        }
    }
        
    func ConfirmationDeleteOverlay() -> some View {
        // Full-screen overlay with centered content
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
}
