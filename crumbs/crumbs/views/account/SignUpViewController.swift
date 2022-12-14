//
//  SignUpViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/14/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

extension String {
   var isValidEmail: Bool {
      let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
      return testEmail.evaluate(with: self)
   }
}

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameAlert: UILabel!
    @IBOutlet weak var passwordAlert: UILabel!
    @IBOutlet weak var confirmPasswordAlert: UILabel!
    @IBOutlet weak var dateOfBirthAlert: UILabel!
    @IBOutlet weak var emailAlert: UILabel!
    @IBOutlet weak var createAccountAlert: UILabel!
    
    @IBOutlet weak var createAccountButton: UIButton!
    let usernameEmptyAlert = "Please enter a username"
    let passwordEmptyAlert = "Please enter a password"
    let confirmPasswordEmptyAlert = "Please confirm your password"
    let emailEmptyAlert = "Please enter your email"
    let oldestAge = 120
    let youngestAge = 13
    
    var textFieldAlertMap:[UITextField:UILabel] = [:]
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldAlertMap = [
            usernameTextField:usernameAlert,
            passwordTextField:passwordAlert,
            confirmPasswordTextField:confirmPasswordAlert,
            dateOfBirthTextField:dateOfBirthAlert, emailTextField:emailAlert
        ]
        
        
        self.emailTextField.delegate = self
        self.dateOfBirthTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        createDatePicker()

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
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        var validated = true
        usernameAlert.text = usernameEmptyAlert
        passwordAlert.text = passwordEmptyAlert
        confirmPasswordAlert.text = confirmPasswordEmptyAlert
        emailAlert.text = emailEmptyAlert
        passwordAlert.isHidden = true
        confirmPasswordAlert.isHidden = true
        emailAlert.isHidden = true
        
        for (textField, alert) in textFieldAlertMap {
            if textField.text == "" {
                alert.isHidden = false
                validated = false
            }
        }
        if self.confirmPasswordTextField.text != self.passwordTextField.text {
            self.confirmPasswordAlert.text = "Passwords must match"
            self.passwordAlert.text = "Passwords must match"
            
            self.confirmPasswordAlert.isHidden = false
            self.passwordAlert.isHidden = false
            
            validated = false
        }
        if emailAlert.isHidden && !self.emailTextField.text!.isValidEmail {
            self.emailAlert.text = "Please enter a valid email"
            self.emailAlert.isHidden = false
            validated = false
        }
        
        // await create auth user
        if validated {
            self.showSpinner(onView: self.view)
            let username = usernameTextField.text!
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if let error = error as NSError? {
                    self.createAccountAlert.text = "\(error.localizedDescription)"
                } else {
                    User(uid: authResult!.user.uid, username: username, birthday: self.datePicker.date) {
                        success in
                        
                        let db = Firestore.firestore()
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
                                        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: HOME_TAB_BAR_CONTROLLER_IDENTIFIER)
                                        self.view.window?.rootViewController = homeViewController
                                        self.view.window?.makeKeyAndVisible()
                                    }
                                }

                            }
                        }
                    }
                    self.createAccountAlert.text = "Success"
                }
            }
        }
    }
    
    @IBAction func editingEnded(_ sender: Any) {
        let textField = sender as! UITextField
        let username = textField.text!
        let db = Firestore.firestore()
        db.collection("users").whereField("username", isEqualTo: username).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.documents.count > 0 {
                    self.usernameAlert.text = "Username taken"
                    self.usernameAlert.isHidden = false
                } else {
                    self.usernameAlert.isHidden = true
                }
            }
        }
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        let textField = sender as! UITextField
        if let alert = textFieldAlertMap[textField] {
            alert.isHidden = true
        }
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneWithBirthday))
        toolbar.setItems([doneButton], animated: true)
        return toolbar
    }
    
    func createDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -oldestAge, to: Date())
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -youngestAge, to: Date())
        dateOfBirthTextField.inputView = datePicker
        dateOfBirthTextField.inputAccessoryView = createToolbar()
    }

    @objc func doneWithBirthday() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateOfBirthTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }

}
