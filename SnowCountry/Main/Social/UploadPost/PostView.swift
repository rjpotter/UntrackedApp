//
//  PostView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/24/24.  
//

import SwiftUI

struct PostView: View {
    @State var images: [UIImage]
    @State private var caption: String = ""
    @State private var selectedIndex: Int = 0
    @State private var isFullScreen: Bool = false
    @State private var isEditing: Bool = false
    @State private var showStokeLevelPicker: Bool = false
    @State private var showTagPeople: Bool = false
    @State private var showLocationPicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Display the collage of images
                    CollageView(images: images)
                        .onTapGesture {
                            isFullScreen = true
                        }

                    // Caption input
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $caption)
                            .padding(4)
                            .frame(minHeight: 20, maxHeight: 100)
                            .onTapGesture {
                                isEditing = true
                            }
                            .onChange(of: caption) { _ in
                                isEditing = true
                            }
                        
                        if caption.isEmpty && !isEditing {
                            Text("Write a caption...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Additional options similar to Instagram
                    VStack {
                        OptionRow(icon: "star", title: "Rate Stoke Level") {
                            showStokeLevelPicker.toggle()
                        }
                        .sheet(isPresented: $showStokeLevelPicker) {
                            // StokeLevelPickerView()
                        }
                        
                        OptionRow(icon: "person.crop.circle", title: "Tag people") {
                            showTagPeople.toggle()
                        }
                        .sheet(isPresented: $showTagPeople) {
                            // TagPeopleView()
                        }
                        
                        OptionRow(icon: "map.circle", title: "Add Location") {
                            showLocationPicker.toggle()
                        }
                        .sheet(isPresented: $showLocationPicker) {
                            // LocationPickerView()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            if !isEditing {
                // Share button fixed at the bottom
                Button(action: {
                    // Handle post action
                }) {
                    Text("Share")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .onTapGesture {
            endEditing(true)
        }
        .sheet(isPresented: $isFullScreen, content: {
            FullScreenImageView(images: images, selectedIndex: $selectedIndex, isPresented: $isFullScreen)
        })
        .navigationTitle("New Post")
    }
    
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force) }
    }
}

struct OptionRow: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 10)
            }
            .padding(.vertical, 10)
            .padding(.leading)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    @State static var exampleImages: [UIImage] = (1...10).compactMap { UIImage(named: "photo\($0)") }
    
    static var previews: some View {
        PostView(images: exampleImages)
    }
}
