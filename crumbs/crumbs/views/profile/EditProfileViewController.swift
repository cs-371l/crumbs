//
//  EditProfileViewController.swift
//  crumbs
//
//  Created by Amog Iska on 11/7/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {

    var user: User = CUR_USER
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var emailAlert: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = user.username
        biographyTextField.text = user.biography
        emailTextField.text = Auth.auth().currentUser?.email
        emailAlert.isHidden = true
    }
    
    @IBOutlet weak var backButton: UINavigationItem!
    
    
    
    @IBAction func editBiographyButton(_ sender: Any) {
        user.biography = biographyTextField.text!
        user.docRef.updateData(["bio": user.biography])
    }
    
    @IBAction func editEmailButton(_ sender: Any) {
        if emailTextField.text!.isValidEmail {
            emailAlert.isHidden = true
            Auth.auth().currentUser?.updateEmail(to: emailTextField.text!)
        } else {
            emailAlert.isHidden = false
            emailTextField.text = Auth.auth().currentUser?.email
        }     
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
