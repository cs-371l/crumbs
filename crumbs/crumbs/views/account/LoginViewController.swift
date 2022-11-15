//
//  LoginViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/14/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var usernameError: UILabel!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextField: UILabel!
    
    let signupSegueIdentifier = "SignUpPageSegue"
    let missingPasswordError = "Please enter a password."
    let missingUsernameError = "Please enter an email."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        setupAppleButton()
        setupErrors()
        
        // change button colors
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 0
        loginButton.backgroundColor = UIColorFromRGB(rgbValue: 0x5399dd)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        
        signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 0
        signupButton.backgroundColor = UIColorFromRGB(rgbValue: 0x5399dd)
        signupButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // adds crumbs logo to navbar
    func addNavBarImage() {
            let navController = navigationController!
            let image = UIImage(named: "NavbarLogo.png") //Your logo url here
            let imageView = UIImageView(image: image)
            let bannerWidth = navController.navigationBar.frame.size.width
            let bannerHeight = navController.navigationBar.frame.size.height
            let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
            let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
            imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
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
            let db = Firestore.firestore()
                    Auth.auth().signIn(
                        withEmail: self.usernameTextField.text!,
                        password: self.passwordTextField.text!) {
                            authResult, error in
                            if let error = error as NSError? {
                                self.errorTextField.text! = "\(error.localizedDescription)"
                            } else {
                                self.errorTextField.text = "Success"
                                db.collection("users").document(authResult!.user.uid).getDocument() {
                                    (snapshot, err) in
                                    if let err = err {
                                        self.showErrorAlert(title: "Error", message: "Unable to sign in.")
                                        print(err.localizedDescription)
                                        return
                                    } else {
                                        CUR_USER = User(snapshot: snapshot!)
                                        
                                        CUR_USER.getPosts {
                                            success, posts in
                                            if !success {
                                                self.showErrorAlert(title: "Error", message: "Unable to load profile.")
                                                return
                                            }
                                            DispatchQueue.main.async {
                                                self.removeSpinner()
                                            }
                                            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: HOME_TAB_BAR_CONTROLLER_IDENTIFIER)
                                            self.view.window?.rootViewController = homeViewController
                                            self.view.window?.makeKeyAndVisible()
                                        }

                                    }
                                }
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
