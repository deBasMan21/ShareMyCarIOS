
import SwiftUI
import UIKit

struct PhotoPicker: UIViewControllerRepresentable{
    @Binding var image : UIImage
    @State var onSucces : (_ : UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        
        return Coordinator(photoPicker: self)
    }
    
    final class Coordinator : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let photoPicker: PhotoPicker
        
        init(photoPicker : PhotoPicker) {
            self.photoPicker = photoPicker
            
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                photoPicker.image = image
                photoPicker.onSucces(image)
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
}
