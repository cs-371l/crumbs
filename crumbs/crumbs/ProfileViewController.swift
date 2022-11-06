//
//  ProfileViewController.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import UIKit
import FirebaseAuth

extension UIImageView {

   func setRounded() {
       let radius = self.frame.width / 2
      self.layer.cornerRadius = radius
      self.layer.masksToBounds = true
   }
}

class ProfileViewController: UIViewController {
    
    var user: User = CUR_USER
    
    private final let POST_CARD_EMBED_SEGUE = "ProfileToCardSegue"
    private final let ABOUT_EMBED_SEGUE = "ProfileToAboutSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

        image.setRounded()
        username.text = user.username
        biography.text = user.biography
        postsView.isHidden = true
        aboutView.isHidden = false
        
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
    
    @IBOutlet weak var biography: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going into post view, pass in the post.
        if segue.identifier == POST_CARD_EMBED_SEGUE, let nextVC = segue.destination as? PostCardViewController {
            nextVC.posts = self.user.posts
        } else if segue.identifier == ABOUT_EMBED_SEGUE , let nextVC = segue.destination as? AboutViewController {
            nextVC.user = self.user
        }
    }

}
