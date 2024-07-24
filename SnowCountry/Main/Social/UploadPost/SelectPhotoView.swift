//
//  SelectPhotoView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/23/24.
//

import SwiftUI
import PhotosUI

struct SelectPhotoView: View {
    @State private var fetchedImages: [UIImage] = []
    @State private var selectedImages: [UIImage] = []
    var mapImage: UIImage
    @State private var fetchOffset = 0
    @State private var isLoading = false
    @State private var totalAssetsCount = 0
    @State private var fetchResult: PHFetchResult<PHAsset>?

    var body: some View {
        VStack {
            // Display the selected images in a horizontal scroll view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Show the map image as the first photo
                    if selectedImages.isEmpty {
                        Spacer() // Center the map image if it's the only image
                        Image(uiImage: mapImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .padding(.horizontal, 10)
                        Spacer() // Center the map image if it's the only image
                    } else {
                        Image(uiImage: mapImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .padding(.leading, 10)
                        
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .padding(.leading, 10)
                        }
                    }
                }
            }
            .frame(height: 270)

            Spacer()

            // Display the photo library in a grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 4), spacing: 2) {
                    ForEach(fetchedImages, id: \.self) { image in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 4 - 2, height: UIScreen.main.bounds.width / 4 - 2)
                                .clipped()
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    print("Toggling selection for image: \(image)")
                                    toggleSelection(for: image)
                                }
                                .overlay(
                                    overlayView(for: image)
                                        .onTapGesture {
                                            print("Toggling selection for image: \(image)")
                                            toggleSelection(for: image)
                                        }
                                )
                                .onAppear {
                                    if fetchedImages.firstIndex(of: image) == fetchedImages.count - 1 && !isLoading && fetchOffset < totalAssetsCount {
                                        print("Last image appeared, loading more photos")
                                        loadPhotos()
                                    }
                                }
                        }
                    }
                }
                .padding(10)
                if isLoading {
                    ProgressView()
                        .padding()
                }
            }
        }
        .navigationTitle("Select Photos")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: PhotoAdjustView(images: [mapImage] + selectedImages)) {
                    Text("Next")
                }
            }
        }
        .onAppear(perform: loadInitialPhotos)
    }

    private func toggleSelection(for image: UIImage) {
        if let selectedIndex = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: selectedIndex)
        } else if selectedImages.count < 9 {
            selectedImages.append(image)
        }
    }

    private func overlayView(for image: UIImage) -> some View {
        if let index = selectedImages.firstIndex(of: image) {
            return AnyView(
                ZStack {
                    Color.black.opacity(0.5)
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "\(index + 1).circle.fill")
                                .symbolRenderingMode(.palette)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white, .pink)
                                .padding(5)
                        }
                        Spacer()
                    }
                }
            )
        } else {
            return AnyView(Color.clear)
        }
    }

    private func loadInitialPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    loadTotalAssetsCount()
                }
            }
        }
    }

    private func loadTotalAssetsCount() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)

        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        totalAssetsCount = fetchResult?.count ?? 0

        loadPhotos()
    }

    private func loadPhotos() {
        guard !isLoading else { return }
        isLoading = true

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 50
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)

        let imageManager = PHCachingImageManager()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat

        var newImages: [UIImage] = []
        let startIndex = fetchOffset
        let endIndex = min(fetchOffset + 50, totalAssetsCount)

        guard let fetchResult = fetchResult, startIndex < fetchResult.count else {
            isLoading = false
            return
        }

        let dispatchGroup = DispatchGroup()

        for index in startIndex..<endIndex {
            dispatchGroup.enter()
            let asset = fetchResult.object(at: index)
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    newImages.append(image)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.fetchedImages.append(contentsOf: newImages)
            self.fetchOffset += newImages.count
            self.isLoading = false
        }
    }
}

struct SelectPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPhotoView(mapImage: UIImage(systemName: "photo")!)
    }
}
