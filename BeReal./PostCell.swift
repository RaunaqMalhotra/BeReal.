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
    
    @IBOutlet weak var imageBlurView: UIVisualEffectView!
    
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
        
        // A lot of the following returns optional values so we'll unwrap them all together in one big `if let`
        // Get the current user.
        if let currentUser = User.current,
           
           // Get the date the user last shared a post (cast to Date).
           let lastPostedDate = currentUser.lastPostedDate,
           
           // Get the date the given post was created.
           let postCreatedDate = post.createdAt,
           
           // Get the difference in hours between when the given post was created and the current user last posted.
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {
            
            // Hide the blur view if the given post was created within 24 hours of the current user's last post. (before or after)
            imageBlurView.isHidden = abs(diffHours) < 24
            
        } else {
            // Default to blur if we can't get or compute the date's above for some reason.
            imageBlurView.isHidden = false
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
