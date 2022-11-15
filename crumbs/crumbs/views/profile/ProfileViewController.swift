//
//  ProfileViewController.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension UIImageView {
    
    func makeRounded() {
        let radius = self.frame.width / 2
              self.layer.cornerRadius = radius
              self.layer.masksToBounds = true
    }
}

class ProfileViewController: UIViewController, PostPopulator {
    var user: User = CUR_USER
    
    private final let POST_CARD_EMBED_SEGUE = "ProfileToCardSegue"
    private final let ABOUT_EMBED_SEGUE = "ProfileToAboutSegue"

    var embeddedAbout: AboutViewController?
    var embeddedPost: PostCardViewController?
    @IBOutlet weak var edit: UIButton!
    
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBAction func EditButton(_ sender: Any) {
        // Pass, do nothing.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = user.username
        bio.text = user.biography
        if(user.uiImage != nil){
            profilePic.image = user.uiImage
            self.profilePic.makeRounded()
        } else if(user.imageUrl != nil){
            //spinner doesnot seem to work for some reason but the profile pic loads really quick so need for spinner as of now.
            // self.showSpinner(onView: self.view)
            getData(from: URL(string: user.imageUrl!)!) {
                data, resp, error in
                guard let data = data, error == nil else {
                    self.showErrorAlert(title: "Error", message: "Unable to load post.")
                    return
                }
                DispatchQueue.main.async {
                    self.profilePic.image = UIImage(data: data)
                    self.profilePic.makeRounded()
                    self.user.uiImage = self.profilePic.image
                    // self.removeSpinner()
                    
                }
            }
        }
        
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
                    self.embeddedAbout!.posts = self.user.posts!
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
            let otherUserDocument: DocumentSnapshot
            do {
                try otherUserDocument = transaction.getDocument(self.user.docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldViews = otherUserDocument.data()?["views"] as! Int
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
            nextVC.delegate = self
            self.embeddedPost = nextVC
        } else if segue.identifier == ABOUT_EMBED_SEGUE , let nextVC = segue.destination as? AboutViewController {
            nextVC.user = self.user
            nextVC.posts = self.user.posts ?? []
            self.embeddedAbout = nextVC
        }
    }
    
    func emptyPlaceholderString() -> String {
        return CUR_USER === self.user ? "You haven't made any Crumbs yet." : "This user has not made any Crumbs recently."
    }
    
    func populatePosts(completion: ((_: [Post]) -> Void)?) {
        let db = Firestore.firestore()
        let query = db.collection("posts").whereField("user", isEqualTo: self.user.docRef)
        query.order(by: "timestamp", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            let posts = querySnapshot!.documents.map {Post(snapshot: $0)}
            if completion != nil {
                completion!(posts)
            }
        }
    }

}
