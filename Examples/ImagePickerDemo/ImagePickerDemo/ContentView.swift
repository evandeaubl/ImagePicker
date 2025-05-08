//
//  ContentView.swift
//  ImagePickerDemo
//
//  Created by Evan Deaubl on 5/7/25.
//

import SwiftUI
import ImagePicker

struct ContentView: View {
    @State private var selectedImage: Image?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ImagePicker Demo")
                .font(.title)
                .fontWeight(.bold)
            
            // ImagePicker component
            ImagePicker(image: $selectedImage)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
                .shadow(radius: 5)
            
            // Display selected image information
            if let selectedImage = selectedImage {
                VStack(spacing: 10) {
                    Text("Selected Image:")
                        .font(.headline)
                    
                    selectedImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
                    .italic()
            }
            
            Spacer()
            
            // Instructions
            VStack(alignment: .leading, spacing: 5) {
                Text("Instructions:")
                    .font(.headline)
                Text("• Tap the image picker to select a photo")
                Text("• Choose from photo library" + (UIImagePickerController.isSourceTypeAvailable(.camera) ? " or camera" : ", camera, or files"))
                Text("• Paste from clipboard if an image is available")
                Text("• Tap the X button to clear the image")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
