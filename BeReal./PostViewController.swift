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
    
    
    @IBAction func onOpenCameraDidTap(_ sender: Any) {
        // Make sure the user's camera is available
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }
        
        // Instantiate the image picker
        let imagePicker = UIImagePickerController()
        
        // Shows the camera
        imagePicker.sourceType = .camera
        
        // Allows user to edit image within image picker flow (i.e. crop, etc.)
        imagePicker.allowsEditing = true
        
        // The image picker (camera in this case) will return captured photos via it's delegate method to it's assigned delegate.
        // Delegate assignee must conform and implement both `UIImagePickerControllerDelegate` and `UINavigationControllerDelegate`
        imagePicker.delegate = self
        
        // Present the image picker (camera)
        present(imagePicker, animated: true)
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
                    
                    // Get the current user
                    if var currentUser = User.current {
                        
                        // update the lastPostedDate property on the user with the current date
                        currentUser.lastPostedDate = Date()
                        
                        // Save updates to the user (async)
                        currentUser.save { [weak self] result in
                            switch result {
                            case .success(let user):
                                print("✅ User Saved! \(user)")
                                // Switch to the main thread for any UI updates
                                DispatchQueue.main.async {
                                    // Return to previous view controller
                                    self?.navigationController?.popViewController(animated: true)
                                }
                                
                            case .failure(let error):
                                self?.showAlert(description: error.localizedDescription)
                            }
                        }
                    }
                    
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

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Dismiss the image picker
        picker.dismiss(animated: true)
        
        // Get the edited image from the info dictionary
        guard let image = info[.editedImage] as? UIImage else {
            print("❌📷 Unable to get image")
            return
        }
        
        // Set the image on preview image view
        previewImage.image = image
        
        // Set image to use when saving post
        pickedImage = image
    }
}
