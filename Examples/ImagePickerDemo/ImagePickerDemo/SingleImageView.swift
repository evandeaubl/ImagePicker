//
// Copyright (c) 2025 Evan Deaubl. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import ImagePicker

struct SingleImageView: View {
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
                Text("• Choose from photo library, camera, or files")
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
    SingleImageView()
}
