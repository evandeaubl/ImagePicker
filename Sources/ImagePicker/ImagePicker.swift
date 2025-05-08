// The Swift Programming Language
// https://docs.swift.org/swift-book

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
    
    /// Size of the image picker view
    private var size: CGSize
    
    /// Corner radius of the image picker view
    private var cornerRadius: CGFloat
    
    /// State to control the photo picker presentation
    @State private var showingPhotoPicker = false
    
    /// State to control the camera presentation
    @State private var showingCamera = false
    
    /// PhotosPickerItem from the photo library selection
    @State private var selectedItem: PhotosPickerItem?
    
    /// State to track if clipboard contains a compatible image
    @State private var clipboardHasImage = false
    
    /// Flag indicating if camera is available on the device
    private let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    
    /// Initializes a new ImagePicker view
    /// - Parameters:
    ///   - image: Binding to the optional image
    ///   - size: Size of the image picker view (default: 150x150)
    ///   - cornerRadius: Corner radius of the image picker view (default: 8)
    public init(
        image: Binding<Image?>,
        size: CGSize = CGSize(width: 150, height: 150),
        cornerRadius: CGFloat = 8
    ) {
        self._image = image
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    /// Checks if the clipboard contains a compatible image
    private func checkClipboardForImage() {
        clipboardHasImage = UIPasteboard.general.hasImages
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content - either the image or the placeholder
            Menu {
                Button {
                    showingPhotoPicker = true
                } label: {
                    Label("Photo Library", systemImage: "photo.stack")
                }
                
                if isCameraAvailable {
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                    }
                }
                
                if clipboardHasImage {
                    Button {
                        if let uiImage = UIPasteboard.general.image {
                            image = Image(uiImage: uiImage)
                        }
                    } label: {
                        Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                    }
                }
                
                if image != nil {
                    Button(role: .destructive) {
                        image = nil
                    } label: {
                        Label("Remove Image", systemImage: "trash")
                    }
                }
            } label: {
                Group {
                    if let image = image {
                        // Display the selected image
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        // Display the placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color(.systemGray5))
                            
                            Image(systemName: isEnabled ? "plus" : "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(Rectangle())
            
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
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        image = Image(uiImage: uiImage)
                        selectedItem = nil
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(image: $image)
                .ignoresSafeArea()
        }
        .onAppear {
            checkClipboardForImage()
        }
    }
}

/// A UIViewControllerRepresentable wrapper for UIImagePickerController to capture images from the camera
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var image: Image? = nil
        
        var body: some View {
            VStack {
                ImagePicker(image: $image)
                
                if image != nil {
                    Text("Image selected")
                } else {
                    Text("No image selected")
                }
                
                Button("Reset") {
                    image = nil
                }
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
