//
//  CollageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/24/24.
//

import SwiftUI
import Kingfisher

struct CollageView: View {
    var images: [UIImage]

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width * 3 / 4 // 4:3 aspect ratio

            HStack(spacing: 0) {
                // First image takes 3/4 of the space
                if let firstImage = images.first {
                    Spacer()
                    
                    Image(uiImage: firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width * 3 / 4, height: height)
                        .clipped()
                    
                    Spacer()
                }

                VStack(spacing: 0) {
                    // Second image takes 1/2 of the remaining 1/4 space
                    if images.count > 1 {
                        Image(uiImage: images[1])
                            .resizable()
                            .scaledToFill()
                            .frame(width: width / 4, height: height / 2)
                            .clipped()
                    }

                    // Third image takes the remaining space
                    if images.count > 2 {
                        ZStack {
                            Image(uiImage: images[2])
                                .resizable()
                                .scaledToFill()
                                .frame(width: width / 4, height: height / 2)
                                .clipped()

                            // Overlay with the number of additional images
                            if images.count > 3 {
                                Rectangle()
                                    .fill(Color.black.opacity(0.6))
                                Text("+\(images.count - 3)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(height: height) // Ensure the height is consistent
            }
            .clipped()
        }
        .frame(height: UIScreen.main.bounds.width * 3 / 4) // Adjusted to match aspect ratio
        .clipped()
    }
}

struct CollageViewURL: View {
    var imageURLs: [String]

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width * 3 / 4 // 4:3 aspect ratio

            HStack(spacing: 0) {
                // First image takes 3/4 of the space
                if let firstImageURL = imageURLs.first, let url = URL(string: firstImageURL) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width * 3 / 4, height: height)
                        .clipped()
                }

                VStack(spacing: 0) {
                    // Second image takes 1/2 of the remaining 1/4 space
                    if imageURLs.count > 1, let url = URL(string: imageURLs[1]) {
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width / 4, height: height / 2)
                            .clipped()
                    }

                    // Third image takes the remaining space
                    if imageURLs.count > 2, let url = URL(string: imageURLs[2]) {
                        ZStack {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: width / 4, height: height / 2)
                                .clipped()

                            // Overlay with the number of additional images
                            if imageURLs.count > 3 {
                                Rectangle()
                                    .fill(Color.black.opacity(0.6))
                                Text("+\(imageURLs.count - 3)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(height: height) // Ensure the height is consistent
            }
            .clipped()
        }
        .frame(height: UIScreen.main.bounds.width * 3 / 4) // Adjusted to match aspect ratio
        .clipped()
    }
}

