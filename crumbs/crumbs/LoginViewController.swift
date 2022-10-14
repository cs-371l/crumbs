//
//  LoginViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/14/22.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var appleButton: UIButton!
    let signupSegueIdentifier = "SignUpPageSegue"

    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var usernameError: UILabel!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleButton()
        setupErrors()
        
    }
    
    private func setupErrors() {
        passwordError.text = ""
        usernameError.text = ""
    }
    // Setups the apple button with correct logo and tint.
    @IBAction func editingChangedUsername(_ sender: Any) {
        usernameError.text = ""
    }
    @IBAction func editingChangedPassword(_ sender: Any) {
        passwordError.text = ""
    }
    
    private func checkTextFieldEmpty(textField: UITextField) -> Bool {
        if textField.text == nil {
            return true
        }
        return textField.text == ""
    }

    @IBAction func loginPressed(_ sender: Any) {
        if checkTextFieldEmpty(textField: usernameTextField) {
            usernameError.text = "Please enter a username."
        }
        
        if checkTextFieldEmpty(textField: passwordTextField) {
            passwordError.text = "Please enter a password."
        }
    }
    private func setupAppleButton() {
        let logo = UIImage(systemName: "applelogo")!.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6))
        appleButton.setImage(logo, for: .normal)
        appleButton.tintColor = UIColor.systemGray2
    }
    

    @IBAction func signUpPressed(_ sender: Any) {
        performSegue(withIdentifier: signupSegueIdentifier, sender: self)
    }

}
