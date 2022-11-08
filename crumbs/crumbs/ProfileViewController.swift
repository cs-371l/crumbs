//
//  ProfileViewController.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    var user: User = CUR_USER
    
    private final let POST_CARD_EMBED_SEGUE = "ProfileToCardSegue"
    private final let ABOUT_EMBED_SEGUE = "ProfileToAboutSegue"

    var embeddedAbout: AboutViewController?
    var embeddedPost: PostCardViewController?
    @IBOutlet weak var edit: UIButton!
    
    
    
    @IBAction func EditButton(_ sender: Any) {
        // Pass, do nothing.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading view")
        username.text = user.username
        bio.text = user.biography

        if(segment.selectedSegmentIndex == 0){
            aboutView.isHidden = false
            postsView.isHidden = true
        } else if (segment.selectedSegmentIndex == 1){
            postsView.isHidden = false
            aboutView.isHidden = true
        }
        
        user.getPosts {
            success, posts in
            if !success {
                self.showErrorAlert(title: "Error", message: "Failed to get posts for user.")
                return
            }
            DispatchQueue.main.async {
                if self.embeddedPost != nil {
                    self.embeddedPost!.posts = self.user.posts!
                    self.embeddedPost!.refreshView()
                }
                
                if self.embeddedAbout != nil {
                    self.embeddedAbout!.user = self.user
                    self.embeddedAbout!.refreshView()
                }
            }
        }
        
        if(user.username != CUR_USER.username){
            edit.isHidden = true
            if(!CUR_USER.hasViewedProfile(u: user)){
                user.views += 1
                updateViewsForUser()
            }
        } else {
            edit.isHidden = false
        }
        
    }
    
    func updateViewsForUser() {
        let db = Firestore.firestore()
        db.runTransaction({
            (transaction, errorPointer) -> Any? in
            let currUserDocument: DocumentSnapshot
            let otherUserDocument: DocumentSnapshot
            do {
                try currUserDocument = transaction.getDocument(CUR_USER.docRef)
                try otherUserDocument = transaction.getDocument(self.user.docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldViews = otherUserDocument.data()?["views"] as! Int
            var viewed = currUserDocument.data()?["viewed_profiles"] as! [DocumentReference]
            viewed.append(self.user.docRef)
            transaction.updateData(["views": oldViews + 1], forDocument: self.user.docRef)
            transaction.updateData(
                ["viewed_profiles": FieldValue.arrayUnion([self.user.docRef])], forDocument: CUR_USER.docRef)
            return nil
        }){(object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            }
        }
        
        CUR_USER.addViewedProfile(u: self.user)
    }
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var postsView: UIView!
    
    @IBAction func segmentSelect(_ sender: Any) {
        if(segment.selectedSegmentIndex == 0){
            aboutView.isHidden = false
            postsView.isHidden = true
        } else if (segment.selectedSegmentIndex == 1){
            postsView.isHidden = false
            aboutView.isHidden = true
        }
    }
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var bio: UILabel!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going into post view, pass in the post.
        if segue.identifier == POST_CARD_EMBED_SEGUE, let nextVC = segue.destination as? PostCardViewController {
            nextVC.posts = self.user.posts ?? []
            let db = Firestore.firestore()
            nextVC.query = db.collection("posts").whereField("user", isEqualTo: self.user.docRef)
            self.embeddedPost = nextVC
        } else if segue.identifier == ABOUT_EMBED_SEGUE , let nextVC = segue.destination as? AboutViewController {
            nextVC.user = self.user
            self.embeddedAbout = nextVC
        }
    }

}
