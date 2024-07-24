import SwiftUI
import Photos

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
                    Image(uiImage: mapImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 250)
                        .padding(.leading, 10)

                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .padding(.leading, 10)
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
                                        loadMorePhotos()
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
        .navigationTitle("New Post")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next") {
                    // Action for the Next button
                }
            }
        }
        .onAppear(perform: loadInitialPhotos)
    }

    private func toggleSelection(for image: UIImage) {
        print("Toggling selection for image: \(image)")
        if let selectedIndex = selectedImages.firstIndex(of: image) {
            if selectedIndex == selectedImages.count - 1 {
                print("Removing image at index \(selectedIndex): \(image)")
                selectedImages.remove(at: selectedIndex)
            } else {
                print("Cannot remove image, not the last selected image")
            }
        } else if selectedImages.count < 9 {
            print("Adding image: \(image)")
            selectedImages.append(image)
        } else {
            print("Cannot add more images, limit reached.")
        }
        print("Selected images count: \(selectedImages.count)")
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
                    print("Photo library access authorized, loading initial photos")
                    loadTotalAssetsCount()
                }
            } else {
                print("Photo library access not authorized.")
            }
        }
    }

    private func loadTotalAssetsCount() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)

        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        totalAssetsCount = fetchResult?.count ?? 0
        print("Total assets count: \(totalAssetsCount)")

        loadPhotos()
    }

    private func loadPhotos() {
        guard !isLoading else { return }
        isLoading = true
        print("Loading photos, fetchOffset: \(fetchOffset)")

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
            print("No more photos to load, stopping load")
            return
        }

        let dispatchGroup = DispatchGroup()

        for index in startIndex..<endIndex {
            dispatchGroup.enter()
            let asset = fetchResult.object(at: index)
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    newImages.append(image)
                    print("Fetched image: \(image)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.fetchedImages.append(contentsOf: newImages)
            self.fetchOffset += newImages.count
            self.isLoading = false
            print("Loaded \(newImages.count) new images, total images: \(self.fetchedImages.count)")
        }
    }

    private func loadMorePhotos() {
        guard !isLoading else {
            print("Not loading more photos, already loading")
            return
        }

        if fetchOffset < totalAssetsCount {
            print("Loading more photos, fetchOffset: \(fetchOffset), totalAssetsCount: \(totalAssetsCount)")
            loadPhotos()
        } else {
            print("No more photos to load, fetchOffset: \(fetchOffset), totalAssetsCount: \(totalAssetsCount)")
        }
    }
}

struct SelectPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPhotoView(mapImage: UIImage(systemName: "photo")!)
    }
}
