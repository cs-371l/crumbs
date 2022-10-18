//
//  ProfileViewController.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import UIKit

extension UIImageView {

   func setRounded() {
       let radius = self.frame.width / 2
      self.layer.cornerRadius = radius
      self.layer.masksToBounds = true
   }
}

//this will be replaced by a global variable once we have firebase set up properly
var user = User(username: "j.doe", firstName: "John", lastName: "Doe", biography: "I am awesome", age: 22, karma: 12, postsCreated: 1, views: 20)

class ProfileViewController: UIViewController {

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
