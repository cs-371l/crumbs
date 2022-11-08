//
//  AddCommentViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 11/7/22.
//

import UIKit

class AddCommentViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var commentTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        commentTextView.text = "Add comment"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Comment", style: .done, target: self, action: #selector(self.addComment))
    }
    
    @objc func addComment() {
        let commentText = commentTextView.text!
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add comment"
            textView.textColor = UIColor.lightGray
        }
    }

}
