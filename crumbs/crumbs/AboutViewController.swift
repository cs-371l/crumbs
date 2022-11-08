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

        self.karma.text = String(self.user.karma)
        // TODO: Calculate and display age
        self.age.text = "1d"
        self.views.text = String(self.user.views)
        self.crumbsCreated.text = String(self.user.posts?.count ?? 0)
    }
    
    func refreshView() {
        self.karma.text = String(self.user.karma)
        // TODO: Calculate and display age
        self.age.text = "1d"
        self.views.text = String(self.user.views)
        self.crumbsCreated.text = String(self.user.posts?.count ?? 0)
    }
    

    @IBOutlet weak var karma: UILabel!
    
    @IBOutlet weak var crumbsCreated: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var age: UILabel!
}
