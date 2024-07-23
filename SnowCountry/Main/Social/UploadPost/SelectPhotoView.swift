//
//  SelectPhotoView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/23/24.
//

import SwiftUI
import PhotosUI

struct TransferableUIImage: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw NSError(domain: "Error converting data to UIImage", code: -1, userInfo: nil)
            }
            return TransferableUIImage(image: uiImage)
        }
    }
}

struct SelectPhotoView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    var mapImage: UIImage

    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10 - selectedImages.count,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Select Photos")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .onChange(of: selectedItems) { newItems in
                for newItem in newItems {
                    newItem.loadTransferable(type: TransferableUIImage.self) { result in
                        switch result {
                        case .success(let transferableImage):
                            if let transferableImage = transferableImage {
                                selectedImages.append(transferableImage.image)
                            }
                        case .failure(let error):
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                }
            }

            ScrollView {
                VStack {
                    Image(uiImage: mapImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding()

                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Select Photos")
        .padding()
    }
}

struct SelectPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPhotoView(mapImage: UIImage(systemName: "photo")!)
    }
}
