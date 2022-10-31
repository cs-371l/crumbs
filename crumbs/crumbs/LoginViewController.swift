//
//  LoginViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/14/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: SignInListenerViewController, UITextFieldDelegate {

    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var usernameError: UILabel!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextField: UILabel!
    
    let signupSegueIdentifier = "SignUpPageSegue"
    let missingPasswordError = "Please enter a password."
    let missingUsernameError = "Please enter a username."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        setupAppleButton()
        setupErrors()
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // Initializes errors to be empty.
    private func setupErrors() {
        passwordError.text = ""
        usernameError.text = ""
    }

    // When the user begins editing or changes editing, get rid of errors.
    @IBAction func editingChangedUsername(_ sender: Any) {
        usernameError.text = ""
    }
    // When the user begins editing or changes editing, get rid of errors.
    @IBAction func editingChangedPassword(_ sender: Any) {
        passwordError.text = ""
    }
    
    // Checks if the text field is empty (nil/empty string).
    private func checkTextFieldEmpty(textField: UITextField) -> Bool {
        if textField.text == nil {
            return true
        }
        return textField.text == ""
    }
    
    // Triggers login action, does basic validation that name
    // and password fields are not empty.
    @IBAction func loginPressed(_ sender: Any) {
        if checkTextFieldEmpty(textField: usernameTextField) {
            usernameError.text = missingUsernameError
        }
        
        if checkTextFieldEmpty(textField: passwordTextField) {
            passwordError.text = missingPasswordError
        }
        
        if !checkTextFieldEmpty(textField: usernameTextField) && !checkTextFieldEmpty(textField: passwordTextField) {
                    Auth.auth().signIn(
                        withEmail: self.usernameTextField.text!,
                        password: self.passwordTextField.text!) {
                            authResult, error in
                            if let error = error as NSError? {
                                self.errorTextField.text! = "\(error.localizedDescription)"
                            } else {
                                self.errorTextField.text = "Success"
                            }
                        }
                }
    }
    
    // Setups the apple button with correct logo and tint.
    private func setupAppleButton() {
        // Right inset needed for spacing between text and logo.
        let logo = UIImage(systemName: "applelogo")!.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6))
        appleButton.setImage(logo, for: .normal)
        appleButton.tintColor = UIColor.systemGray2
    }
    
    // Triggers segue to the sign up page.
    @IBAction func signUpPressed(_ sender: Any) {
        performSegue(withIdentifier: signupSegueIdentifier, sender: self)
    }

}
