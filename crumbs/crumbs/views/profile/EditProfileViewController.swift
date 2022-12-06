//
//  EditProfileViewController.swift
//  crumbs
//
//  Created by Amog Iska on 11/7/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

import FirebaseStorage

import CoreImage.CIFilterBuiltins

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user: User = CUR_USER
    private let storage = Storage.storage().reference()
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var passwordButtonOutlet: UIButton!
    @IBOutlet weak var passwordAlert: UILabel!
    @IBOutlet weak var emailAlert: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    var imageToUpload: UIImage? = nil
    @IBOutlet weak var passwordPrompt: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = user.username
        biographyTextField.text = user.biography
        emailTextField.text = Auth.auth().currentUser?.email
        emailAlert.isHidden = true
        passwordAlert.isHidden = true
        passwordPrompt.isHidden = true
        passwordTextField.isHidden = true
        passwordButtonOutlet.isHidden = true
        profilePic.image = CUR_USER.uiImage ?? UIImage(named: "empty-profile-2")
        self.profilePic.makeRounded()
    }
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var backButton: UINavigationItem!
    
    @IBAction func changeButton(_ sender: Any) {
       
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageToUpload = image
        profilePic.image = image
        CUR_USER.uiImage = image
        self.profilePic.makeRounded()
        
        let path = "images/\(NSUUID().uuidString.lowercased()).png"

        let storageRef = storage.child(path)
        
        storageRef.putData(imageToUpload!.pngData()!) {
            _, error in
            guard error == nil else {
                self.showErrorAlert(title: "Error", message: "Failed to upload post.")
                    return
            }
                
                self.storage.child(path).downloadURL {
                    url, error in
                    guard error == nil else {
                        self.showErrorAlert(title: "Error", message: "Failed to upload post.")
                        print(error!.localizedDescription)
                        return
                    }
                    CUR_USER.imageUrl = url!.absoluteString
                    let db = Firestore.firestore()
                    db.runTransaction({
                        (transaction, errorPointer) -> Any? in
                       transaction.updateData(["image_url": CUR_USER.imageUrl], forDocument: CUR_USER.docRef)
                        return nil
                    }){(object, error) in
                        if let error = error {
                            print("Transaction failed: \(error)")
                        }
                    }
                }
            }
        
    }
    
    @IBAction func editBiographyButton(_ sender: Any) {
        user.biography = biographyTextField.text!
        user.docRef.updateData(["bio": user.biography])
    }
    
    @IBAction func editEmailButton(_ sender: Any) {
        if emailTextField.text!.isValidEmail {
            emailAlert.isHidden = true
            passwordPrompt.isHidden = false
            passwordTextField.isHidden = false
            passwordButtonOutlet.isHidden = false
            passwordAlert.isHidden = true
        } else {
            emailAlert.isHidden = false
            passwordPrompt.isHidden = true
            passwordTextField.isHidden = true
            passwordButtonOutlet.isHidden = true
            passwordAlert.isHidden = true
            emailTextField.text = Auth.auth().currentUser?.email
        }     
    }
    
    
    @IBAction func passwordButton(_ sender: Any) {
        guard let password = passwordTextField.text, password != "" else {
            passwordAlert.text =  "Please enter your password"
            passwordAlert.isHidden = false
            return
        }
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: password)
        
        user?.reauthenticate(with: credential) {
            result, error  in
            if error != nil {
                // TODO: Check if error is truly the result of incorrect password
                self.passwordAlert.text = "Wrong password"
                self.passwordAlert.textColor = UIColor.red
                self.passwordAlert.isHidden = false
            } else {
                
                user?.updateEmail(to: self.emailTextField.text!) { (error) in
                                    // email updated
                    self.passwordAlert.text = "Sucessfully Updated Email"
                    self.passwordAlert.textColor = UIColor.black
                    self.passwordAlert.isHidden = false

                    }
            }
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
