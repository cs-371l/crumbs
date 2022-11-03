//
//  AboutViewController.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import UIKit

class AboutViewController: UIViewController {

    var user : User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        karma.text = String(user.karma)
        // TODO: Calculate and display age
        age.text = "1d"
        views.text = String(user.views)
        crumbsCreated.text = String(user.posts.count)
    }
    

    @IBOutlet weak var karma: UILabel!
    
    @IBOutlet weak var crumbsCreated: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var age: UILabel!
}
