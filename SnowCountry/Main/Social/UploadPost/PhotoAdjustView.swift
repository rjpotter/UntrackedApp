//
//  PhotoAdjustView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/24/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct PhotoItemView: View {
    let index: Int
    let image: UIImage
    let draggedImage: UIImage?

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .cornerRadius(10)
    }
}

struct PhotoAdjustView: View {
    @State var images: [UIImage]
    @State private var draggedImage: UIImage?

    var body: some View {
        VStack {
            // Display the main image with swipe navigation
            TabView {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: UIScreen.main.bounds.width * 5 / 4)
            .clipped()
            .background(Color.black.opacity(0.1))

            // Preview bar for quick photo selection and reordering
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images.indices, id: \.self) { index in
                        PhotoItemView(index: index, image: images[index], draggedImage: draggedImage)
                            .onDrag {
                                self.draggedImage = images[index]
                                return NSItemProvider()
                            }
                            .onDrop(of: [.text],
                                    delegate: DropViewDelegate(destinationItem: images[index], images: $images, draggedItem: $draggedImage)
                            )
                            .allowsHitTesting(index != 0 && draggedImage != images[index]) // Prevent re-dragging the same image or dragging the first image
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Adjust Photos")
    }
}

struct DropViewDelegate: DropDelegate {
    
    let destinationItem: UIImage
    @Binding var images: [UIImage]
    @Binding var draggedItem: UIImage?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem {
            let fromIndex = images.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = images.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.images.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}

struct PhotoAdjustView_Previews: PreviewProvider {
    @State static var exampleImages: [UIImage] = (1...10).compactMap { UIImage(named: "photo\($0)") }
    
    static var previews: some View {
        PhotoAdjustView(images: exampleImages)
    }
}
