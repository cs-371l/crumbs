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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        username.text = user.username
        bio.text = user.biography
        postsView.isHidden = true
        aboutView.isHidden = false
        self.showSpinner(onView: self.view)
        
        user.getPosts {
            success, posts in
            if !success {
                self.showErrorAlert(title: "Error", message: "Failed to get posts for user.")
                return
            }
            DispatchQueue.main.async {
                self.removeSpinner()
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
        } else {
            edit.isHidden = false
        }
        
    }
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var postsView: UIView!
    
    @IBAction func segmentSelect(_ sender: Any) {
        postsView.isHidden = true
        aboutView.isHidden = true
        if(segment.selectedSegmentIndex == 0){
            aboutView.isHidden = false
        } else if (segment.selectedSegmentIndex == 1){
            postsView.isHidden = false
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
