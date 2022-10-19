//
//  PostCreationViewController.swift
//  crumbs
//
//  Created by Philo Lin on 10/13/22.
//

import UIKit

class PostCreationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    var delegate: UIViewController!
    
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
        let titleTextStored = titleText.text!
        let descriptionTextStored = descriptionText.text!
        print(titleTextStored)
        print(descriptionTextStored)
    }
    
    // Dismiss keyboard
    // Called when 'return' key pressed

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
