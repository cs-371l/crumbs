//
//  PostCreationViewController.swift
//  crumbs
//
//  Created by Philo Lin on 10/18/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostCreationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(postPressed))

         titleText.delegate = self
         descriptionText.delegate = self
         descriptionText.text = "Share your thoughts!"
         descriptionText.textColor = UIColor.lightGray
         descriptionText.delegate = self
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

         @objc func postPressed() {
             let db = Firestore.firestore()
             let titleTextStored = titleText.text!
             let descriptionTextStored = descriptionText.text!
             let uid = Auth.auth().currentUser!.uid
             let userRef = db.collection("users").document(uid)
             var ref: DocumentReference? = nil
             
             // TODO: Link current user to post
             let user = User(username: "username", firstName: "first", lastName: "last", biography: "", age: 19, karma: 10, views: 1)
             let post = Post(creator: user, description: descriptionTextStored, title: titleTextStored, date: Date(), likeCount: 0, viewCount: 1)
             ref = db.collection("posts").addDocument(data: post.serialize(userRef: userRef)) { err in
                 if let err = err {
                     print("Error adding document: \(err)")
                 } else {
                     
                     let postViewController = (self.storyboard?.instantiateViewController(withIdentifier: "PostViewController")) as! PostViewController
                     postViewController.post = post
                     self.navigationController?.pushViewController(postViewController, animated: true)
                     var viewControllerStack = self.navigationController!.viewControllers
                     viewControllerStack.remove(at: viewControllerStack.count - 2)
                     self.navigationController?.setViewControllers(viewControllerStack, animated: false)
                     
                     print(self.navigationController!.viewControllers)
                     print("Document added with ID: \(ref!.documentID)")
                 }
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
