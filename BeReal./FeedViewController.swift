//
//  FeedViewController.swift
//  BeReal.
//
//  Created by Raunaq Malhotra on 3/28/23.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTable: UITableView!
    
    private var posts = [Post]() {
        didSet {
            // Reload table view data any time the posts variable gets updated.
            feedTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTable.delegate = self
        feedTable.dataSource = self
        feedTable.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }
    
    private func queryPosts() {

        // 1. Create a query to fetch Posts
        // 2. Any properties that are Parse objects are stored by reference in Parse DB and as such need to explicitly use `include_:)` to be included in query results.
        // 3. Sort the posts by descending order based on the created at date
        
        // Get the date for yesterday. Adding (-1) day is equivalent to subtracting a day.
        // NOTE: `Date()` is the date and time of "right now".
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate) // Only include results created yesterday onwards
            .limit(10) // Limit max number of returned posts to 10
        
        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update local posts property with fetched posts
                self?.posts = posts
                
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }
    
    @IBAction func onLogOutDidTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// create extension to comply with Table data source and table view delegate
extension FeedViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}
