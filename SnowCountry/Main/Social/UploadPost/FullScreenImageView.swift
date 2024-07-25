//
//  FullScreenImageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/24/24.
//

import SwiftUI

struct FullScreenImageView: View {
    var images: [UIImage]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
            .background(Color.black.opacity(0.8))
            
            TabView(selection: $selectedIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                        .background(Color.black)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            HStack {
                Spacer()
                Text("\(selectedIndex + 1) / \(images.count)")
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            .background(Color.black.opacity(0.8))
        }
    }
}
