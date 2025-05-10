# ImagePicker

A flexible and user-friendly SwiftUI component for selecting images in iOS and visionOS applications.

## Features

- 📱 Native SwiftUI implementation
- 📷 Multiple image sources:
  - Photo library
  - Camera (iOS only)
  - Files
  - Clipboard
- 🎨 Customizable appearance
- 🔄 Simple binding-based API
- 🧩 Support for single image or multiple image selection
- 🌐 iOS 16+ and visionOS 2+ support

## Requirements

- iOS 16.0+ / visionOS 2.0+
- Swift 5+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ImagePicker.git", from: "0.1.0")
]
```

Or add it directly through Xcode:
1. Go to File > Add Packages...
2. Enter the repository URL: `https://github.com/yourusername/ImagePicker.git`
3. Select the version you want to use

## Usage

### Basic Usage

```swift
import SwiftUI
import ImagePicker

struct ContentView: View {
    @State private var selectedImage: Image?
    
    var body: some View {
        VStack {
            // Basic image picker
            ImagePicker(image: $selectedImage)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            // Display the selected image
            if let selectedImage = selectedImage {
                selectedImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Text("No image selected")
            }
        }
        .padding()
    }
}
```

### Multiple Image Selection

```swift
import SwiftUI
import ImagePicker

struct MultipleImageView: View {
    @State private var images: [UUID: Image] = [:]
    
    var body: some View {
        VStack {
            // Display grid of images
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(Array(images.keys), id: \.self) { id in
                    if let image = images[id] {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                    }
                }
            }
            
            // Add button with ImagePickerMenu
            ImagePickerMenu(image: Binding<Image?>(
                get: { nil },
                set: { newImage in
                    if let newImage = newImage {
                        images[UUID()] = newImage
                    }
                }
            )) {
                Text("Add Image")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
```

### Custom Styling

The `ImagePicker` view can be customized using standard SwiftUI modifiers:

```swift
ImagePicker(image: $selectedImage)
    .frame(width: 300, height: 200)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .overlay(
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.blue, lineWidth: 2)
    )
    .shadow(radius: 5)
```

## Components

### ImagePicker

A SwiftUI view that displays an optional image with the ability to select from photo library, capture from camera, or clear the image.

```swift
ImagePicker(image: $selectedImage)
```

### ImagePickerMenu

A menu component that provides options for selecting images from various sources. This can be used with a custom button or UI element.

```swift
ImagePickerMenu(image: $selectedImage) {
    // Your custom button or view here
    Text("Select Image")
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
}
```

## Example App

The package includes an example app demonstrating:

1. **Single Image Selection**: Basic usage of the `ImagePicker` component
2. **Image Grid**: Using `ImagePickerMenu` for multiple image selection in a grid layout

## License

This package is available under the MIT license. See the LICENSE file for more info.
