//
//  SignUpViewController.swift
//  BeReal.
//
//  Created by Raunaq Malhotra on 3/27/23.
//

import UIKit
import ParseSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onSignUpDidTap(_ sender: Any) {
        
        print("🥰 Button was tapped")
        
        // Make sure all fields are non-nil and non-empty.
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
        }

        let newUser = User(username: username, email: email, password: password)
        
        newUser.signup { [weak self] result in
            
            switch result{
            case .success(let user):
                print("✅ Successfully signed up user \(user)")
                // Post a notification that the user has successfully signed up
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
            case .failure(let error):
                // Failed sign up
                self?.showAlert(description: error.localizedDescription)
            }
            
        }
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to log you in.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}
