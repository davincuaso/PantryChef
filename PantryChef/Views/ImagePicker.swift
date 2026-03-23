//
//  ImagePicker.swift
//  PantryChef
//
//  UIViewControllerRepresentable for camera and photo library access
//

import SwiftUI
import PhotosUI

// MARK: - Camera Picker (UIImagePickerController)

/// A SwiftUI wrapper for UIImagePickerController to access the camera
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Library Picker (PHPickerViewController)

/// A SwiftUI wrapper for PHPickerViewController to access the photo library
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker

        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.parent.image = image
                    }
                }
            }
        }
    }
}

// MARK: - Image Source Selection Sheet

/// Enum representing available image sources
enum ImageSource: String, CaseIterable, Identifiable {
    case camera = "Camera"
    case photoLibrary = "Photo Library"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .camera:
            return "camera.fill"
        case .photoLibrary:
            return "photo.on.rectangle"
        }
    }
}

/// A view for selecting between camera and photo library
struct ImageSourcePicker: View {
    @Binding var selectedSource: ImageSource?
    @Binding var isPresented: Bool
    let onSourceSelected: (ImageSource) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(ImageSource.allCases) { source in
                    Button {
                        onSourceSelected(source)
                        isPresented = false
                    } label: {
                        Label(source.rawValue, systemImage: source.systemImage)
                    }
                    .disabled(source == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera))
                }
            }
            .navigationTitle("Select Image Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.height(200)])
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedSource: ImageSource?
        @State private var isPresented = true

        var body: some View {
            ImageSourcePicker(
                selectedSource: $selectedSource,
                isPresented: $isPresented,
                onSourceSelected: { _ in }
            )
        }
    }

    return PreviewWrapper()
}
