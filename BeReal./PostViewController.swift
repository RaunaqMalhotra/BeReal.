//
//  PostViewController.swift
//  BeReal.
//
//  Created by Raunaq Malhotra on 3/28/23.
//

import UIKit
import PhotosUI
import ParseSwift

class PostViewController: UIViewController {

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    
    private var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onSelectPhotoDidTap(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    @IBAction func onSharePhotoDidTap(_ sender: Any) {
        
        // Dismiss Keyboard
        view.endEditing(true)

        // Unwrap optional pickedImage
        guard let image = pickedImage,
              // Create and compress image data (jpeg) from UIImage
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        // Create a Parse File by providing a name and passing in the image data
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        
        // Create Post object
        var post = Post()
        
        post.imageFile = imageFile
        post.caption = caption.text
        post.user = User.current
        
        post.save { [weak self] result in
            
            // Switch to the main thread for any UI updates
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")
                    // Return to previous view controller
                    self?.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }
    
    
    @IBAction func onViewDidTap(_ sender: Any) {
        // Dismiss keyboard
        view.endEditing(true)
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension PostViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else {
                self?.showAlert()
                return
            }
            
            // Check and handle any errors
            if let _ = error {
                self?.showAlert()
                return
            }
            // else update UI with the picked image
            else {
                DispatchQueue.main.async {
                    // Set image on preview image view
                    self?.previewImage.image = image
                    // Set the image to use when saving post
                    self?.pickedImage = image
                }
            }
        }
    }
}
