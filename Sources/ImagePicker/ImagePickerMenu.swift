//
// Copyright (c) 2025 Evan Deaubl. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers

/// A SwiftUI view that builds a menu that allows selecting a image from photo library,
/// capture from camera, or clear the image.
public struct ImagePickerMenu<Label_>: View where Label_ : View {
    /// Binding to the optional image
    @Binding var image: Image?
    
    /// State to control the photo picker presentation
    @State private var showingPhotoPicker = false
    
    /// State to control the document picker presentation
    @State private var showingDocumentPicker = false
    
    /// PhotosPickerItem from the photo library selection
    @State private var selectedItem: PhotosPickerItem?
    
    /// State to track if clipboard contains a compatible image
    @State private var clipboardHasImage = false
    
    #if !os(visionOS)
    /// State to control the camera presentation
    @State private var showingCamera = false
    
    /// Flag indicating if camera is available on the device
    private let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    #endif
    
    private var label: () -> Label_
    
    /// Initializes a new ImagePickerMenu view
    /// - Parameters:
    ///   - image: Binding to the optional image
    ///   - label: Label content to launch the menu
    public init(image: Binding<Image?>, label: @escaping () -> Label_) {
        self._image = image
        self.label = label
    }
    
    /// Checks if the clipboard contains a compatible image
    private func checkClipboardForImage() {
        clipboardHasImage = UIPasteboard.general.hasImages
    }
    
    public var body: some View {
        Menu(content: {
            Button {
                showingPhotoPicker = true
            } label: {
                Label("Photo Library", systemImage: "photo.stack")
            }
            
            #if !os(visionOS)
            if isCameraAvailable {
                Button {
                    showingCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                }
            }
            #endif
            
            Button {
                showingDocumentPicker = true
            } label: {
                Label("Files", systemImage: "folder")
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
        }, label: self.label)
        .onReceive(NotificationCenter.default.publisher(for: UIPasteboard.changedNotification)) { _ in
            checkClipboardForImage()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            checkClipboardForImage()
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
        #if !os(visionOS)
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(image: $image)
                .ignoresSafeArea()
        }
        #endif
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerView(image: $image)
        }
        .onAppear {
            checkClipboardForImage()
        }
    }
}

#if !os(visionOS)
/// A UIViewControllerRepresentable wrapper for UIImagePickerController to capture images from the camera
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Environment(\.dismiss) var dismiss
    
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
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif

/// A UIViewControllerRepresentable wrapper for UIDocumentPickerViewController to select images from files
struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Define the supported content types (only JPEG, PNG, and HEIC)
        let supportedTypes: [UTType] = [.jpeg, .png, .heic]
        
        // Create a document picker with the supported types
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                // TODO Handle the failure here.
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Attempt to create a UIImage from the selected file
            guard let uiImage = UIImage(contentsOfFile: url.path) else {
                print("Failed to create image from file: \(url.path)")
                parent.dismiss()
                return
            }
            
            // Update the image binding
            parent.image = Image(uiImage: uiImage)
            parent.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
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
