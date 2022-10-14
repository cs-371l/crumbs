//
//  SignUpViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/14/22.
//

import UIKit

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
        
    let passwordEmptyAlert = "Please enter a password"
    let confirmPasswordEmptyAlert = "Please confirm your password"
    
    var textFieldAlertMap:[UITextField:UILabel] = [:]
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldAlertMap = [usernameTextField:usernameAlert, passwordTextField:passwordAlert, confirmPasswordTextField:confirmPasswordAlert, dateOfBirthTextField:dateOfBirthAlert, emailTextField:emailAlert]
        
        self.emailTextField.delegate = self

        // TODO: Date picker for DOB
        // createDatePicker()
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        var validated = true
        passwordAlert.text = passwordEmptyAlert
        confirmPasswordAlert.text = confirmPasswordEmptyAlert
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
        
        if validated {
            // TODO: Direct to discover page
        }
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        let textField = sender as! UITextField
        if let alert = textFieldAlertMap[textField] {
            alert.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        
        toolbar.setItems([doneButton], animated: true)
        
        dateOfBirthTextField.inputAccessoryView = toolbar
        dateOfBirthTextField.inputView = datePicker
    }

}
