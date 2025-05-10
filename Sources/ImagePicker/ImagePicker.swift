//
// Copyright (c) 2025 Evan Deaubl. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers

/// A SwiftUI view that displays an optional image with the ability to select from photo library,
/// capture from camera, or clear the image.
public struct ImagePicker: View {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    /// Binding to the optional image
    @Binding private var image: Image?
    
    /// Initializes a new ImagePicker view
    /// - Parameters:
    ///   - image: Binding to the optional image
    public init(
        image: Binding<Image?>
    ) {
        self._image = image
    }
    
    public var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .topTrailing) {
                // Main content - either the image or the placeholder
                ImagePickerMenu(image: $image) {
                    Group {
                        if let image = image {
                            // Display the selected image
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            // Display the placeholder
                            ZStack {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                
                                Image(systemName: isEnabled ? "plus" : "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(width: geom.size.width, height: geom.size.height)
                }
                
                // X button to clear the image (only shown when an image is present)
                if image != nil && isEnabled {
                    Button(action: {
                        image = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(8)
                }
            }
        }
    }
}
