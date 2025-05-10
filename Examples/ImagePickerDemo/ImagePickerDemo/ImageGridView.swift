//
// Copyright (c) 2025 Evan Deaubl. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import ImagePicker

struct ImageGridView: View {
    // State to store multiple images
    @State private var images: [UUID: Image] = [:]
    
    // Grid layout configuration
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 10)
    ]
    
    var body: some View {
        ZStack {
            // Main content - grid of images or empty state
            ScrollView {
                if images.isEmpty {
                    VStack {
                        Spacer()
                        Text("No images added yet")
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.top, 100)
                        Spacer()
                    }
                    .frame(minHeight: 300)
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(images.keys), id: \.self) { id in
                            if let image = images[id] {
                                imageCell(id: id, image: image)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addButton
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Image Grid")
    }
    
    // Image cell with delete button
    private func imageCell(id: UUID, image: Image) -> some View {
        ZStack(alignment: .topTrailing) {
            image
                .resizable()
                .scaledToFill()
                .frame(minWidth: 100, minHeight: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .clipped()
                .shadow(radius: 2)
                .allowsHitTesting(false)
            
            // Delete button
            Button(action: {
                withAnimation {
                    _ = images.removeValue(forKey: id)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .padding(5)
        }
    }
    
    // Floating action button to add images
    private var addButton: some View {
        // Temporary image binding for the menu
        let tempImageBinding = Binding<Image?>(
            get: { nil },
            set: { newImage in
                if let newImage = newImage {
                    let id = UUID()
                    withAnimation {
                        images[id] = newImage
                    }
                }
            }
        )
        
        return ImagePickerMenu(image: tempImageBinding) {
            Circle()
                .fill(Color.blue)
                .frame(width: 60, height: 60)
                .shadow(radius: 3)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }
}

#Preview {
    ImageGridView()
}
