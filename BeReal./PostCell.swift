//
//  PostCell.swift
//  BeReal.
//
//  Created by Raunaq Malhotra on 3/28/23.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    private var imageDataRequest: DataRequest?
    
    func configure(with post: Post) {
        // Username
        if let user = post.user {
            username.text = user.username
        }
        
        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            
            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    print("✅ Post Saved!")
                    print(image)
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                    
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }
        
        caption.text = post.caption ?? ""
        
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }
}

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset image view image.
        postImageView.image = nil
        
        // Cancel image request.
        imageDataRequest?.cancel()
    }

}
