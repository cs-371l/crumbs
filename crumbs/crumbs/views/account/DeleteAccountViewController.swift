//
//  DeleteAccountViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/31/22.
//

import UIKit
import FirebaseAuth

class DeleteAccountViewController: SignOutListenerViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    var deleteAccountAction: UIAlertAction!
    var deleteAccountPromptAnswer = "delete my account"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func checkForCorrectAnswer(_ textField:UITextField) {
        if textField.text == deleteAccountPromptAnswer {
            self.deleteAccountAction.isEnabled = true
        } else {
            self.deleteAccountAction.isEnabled = false
        }
    }
    
    func handleAccountDeletion(credential: AuthCredential) {
        let user = Auth.auth().currentUser
        var shouldReauthenticate = false
        
        user?.delete { error in
            if error != nil {
                // TODO: Make a more fine-grained check for whether we should reauthenticate or not
                shouldReauthenticate = true
            }
        }
        
        if shouldReauthenticate {
            user?.reauthenticate(with: credential)
            user?.delete { error in
                if error != nil {
                    print("Error deleting account: %@", error!)
                }
            }
        }
    }
    
    func displayAccountDeletionPrompt(credential: AuthCredential) {
        let controller = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? Please type '\(self.deleteAccountPromptAnswer)' to proceed.",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel",
                                           style: .cancel))
        
        self.deleteAccountAction = UIAlertAction(title: "Delete Account",
                                           style: .destructive,
                                           handler: {
            (paramAction:UIAlertAction!) in
            self.handleAccountDeletion(credential: credential)
        })
        self.deleteAccountAction.isEnabled = false
        
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in textField.addTarget(self, action: #selector(self.checkForCorrectAnswer), for: .editingChanged)
        })
        controller.addAction(deleteAccountAction)
        
        self.present(controller,animated:true)
    }
    
    @IBAction func passwordFieldChanged(_ sender: Any) {
        passwordErrorLabel.isHidden = true
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        
        // TODO: Possibly randomize answer to confirm account deletion?
        
        guard let password = passwordTextField.text, password != "" else {
            passwordErrorLabel.text =  "Please enter your password"
            passwordErrorLabel.isHidden = false
            return
        }
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: password)
        
        user?.reauthenticate(with: credential) {
            result, error  in
            if error != nil {
                // TODO: Check if error is truly the result of incorrect password
                self.passwordErrorLabel.text = "Wrong password"
                self.passwordErrorLabel.isHidden = false
            } else {
                self.displayAccountDeletionPrompt(credential: credential)
            }
        }
    }

}
