//
//  AddCommentViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 11/7/22.
//

import UIKit
import FirebaseFirestore

class AddCommentViewController: UIViewController, UITextViewDelegate {
    
    var post: Post!
    var postViewTable: UITableView!

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var postTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        commentTextView.text = "Add comment"
        commentTextView.textColor = UIColor.lightGray
        postTitleLabel.text = self.post.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(self.addComment))
    }
    
    @objc func addComment() {
        let commentText = commentTextView.text!
        let comment = Comment(
            comment: commentText,
            upvotes: 0,
            username: CUR_USER.username,
            userRef: CUR_USER.docRef,
            date: Date()
        )
        self.post.docRef?.collection("comments").addDocument(data: comment.serialize())
        self.post.comments.append(comment)
        CUR_USER.addFollwedPost(p: self.post)
        self.postViewTable.reloadData()
        self.navigationController?.popViewController(animated: true)
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
