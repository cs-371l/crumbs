//
//  PostCreationViewController.swift
//  crumbs
//
//  Created by Philo Lin on 10/18/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import CoreImage.CIFilterBuiltins


class PostCreationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    
    private final let plus = UIImage(systemName: "plus")
    var imageToUpload: UIImage? = nil
    
    private let storage = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(postPressed))

        titleText.delegate = self
        descriptionText.delegate = self
        descriptionText.text = "Share your thoughts!"
        descriptionText.textColor = UIColor.lightGray
        descriptionText.delegate = self
        
        initializeAddImageButton()
    }
    
    func initializeAddImageButton() {
        for view: UIView in imageButton.imageView?.subviews as! [UIView]{
            view.removeFromSuperview()
        }
        imageButton.setImage(plus, for: .normal)
        imageButton.backgroundColor = UIColor.systemGray6
        imageButton.layer.cornerRadius = 5
    }
    
    func handleImagePicker() {
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
        
        imageButton.imageOverlay(
            image: image,
            backgroundColor: .white,
            overlayBackgroundColor: .black.withAlphaComponent(0.7),
            overlayImage: UIImage(systemName: "x.circle.fill")!.withTintColor(.red),
            imageMargins: 30
        )
        
        imageToUpload = image
        
    }

    @IBAction func imageButtonPressed(_ sender: Any) {
        if imageToUpload == nil {
            handleImagePicker()
        } else {
            initializeAddImageButton()
            imageToUpload = nil
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
             if textView.textColor == UIColor.lightGray {
                 textView.text = nil
                 textView.textColor = UIColor.black
             }
         }

         func textViewDidEndEditing(_ textView: UITextView) {
             if textView.text.isEmpty {
                 textView.text = "Share your thoughts!"
                 descriptionText.textColor = UIColor.lightGray
             }
         }
    
    func uploadPost(post: Post, userRef: DocumentReference) {
            // Creating post.
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            self.showSpinner(onView: self.view)
            ref = db.collection("posts").addDocument(data: post.serialize(userRef: userRef)) { err in
                if let err = err {
                    self.showErrorAlert(title: "Error", message: "Failed to upload post.")
                    print(err.localizedDescription)
                    return
                }
                let postViewController = (self.storyboard?.instantiateViewController(withIdentifier: "PostViewController")) as! PostViewController
                postViewController.post = post
                self.navigationController?.pushViewController(postViewController, animated: true)
                var viewControllerStack = self.navigationController!.viewControllers
                viewControllerStack.remove(at: viewControllerStack.count - 2)
                self.navigationController?.setViewControllers(viewControllerStack, animated: false)
                print("Document added with ID: \(ref!.documentID)")
                DispatchQueue.main.async {
                    self.removeSpinner()
                }
            }
        }

         @objc func postPressed() {
             let db = Firestore.firestore()
             let titleTextStored = titleText.text!
             let descriptionTextStored = descriptionText.text!
             let uid = Auth.auth().currentUser!.uid
             let userRef = db.collection("users").document(uid)
             
             // TODO: Link current user to post
             // TODO: Correctly set date joined, karma, and views
             let user = User(
                username: "username",
                biography: "",
                dateJoined: Date(),
                karma: 10,
                views: 1
             )
             let post = Post(
                creator: user,
                description: descriptionTextStored,
                title: titleTextStored,
                date: Date(),
                likeCount: 0,
                viewCount: 1
             )
             
             // For now store in an images folder with universally unique
             // UUID.
             let path = "images/\(NSUUID().uuidString.lowercased()).png"

             let storageRef = storage.child(path)
             if imageToUpload != nil {
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
                         post.imageUrl = url!.absoluteString
                         self.uploadPost(post: post, userRef: userRef)
                     }
                 }
             } else {
                 uploadPost(post: post, userRef: userRef)
             }
         }

         func textFieldShouldReturn(_ textField:UITextField) -> Bool {
             textField.resignFirstResponder()
             return true
         }

         func textView (_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
             if(text == "\n") {
                 descriptionText.resignFirstResponder()
                 return false
             }
             return true
         }

         // Called when the user clicks on the view outside of the UITextField

         override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
             self.view.endEditing(true)
         }
}
