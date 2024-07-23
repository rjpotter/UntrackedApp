//
//  DebugImageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/23/24.
//

import SwiftUI

struct DebugImageView: View {
    @State private var debugImageURLs: [URL] = []
    @State private var debugImages: [UIImage] = []

    var body: some View {
        VStack {
            Button("Load Debug Images") {
                loadDebugImages()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            ScrollView {
                VStack {
                    ForEach(debugImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Debug View")
        .onAppear {
            loadDebugImages()
        }
    }

    private func loadDebugImages() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        print("Documents directory: \(documentsDirectory.path)")

        let debugImageNames = ["MapSnapshot.png", "StatsOverlay.png", "FinalImage.png"]
        debugImageURLs = debugImageNames.compactMap { imageName in
            let imageURL = documentsDirectory.appendingPathComponent(imageName)
            let exists = fileManager.fileExists(atPath: imageURL.path)
            print("Checking path: \(imageURL.path), exists: \(exists)")
            return exists ? imageURL : nil
        }

        debugImages = debugImageURLs.compactMap { url in
            guard let data = try? Data(contentsOf: url) else { return nil }
            return UIImage(data: data)
        }
    }
}
