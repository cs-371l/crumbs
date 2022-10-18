//
//  AboutViewController.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import UIKit

class AboutViewController: UIViewController {

    var user = User(username: "j.doe", firstName: "John", lastName: "Doe", biography: "I am awesome", age: 22, karma: 12, postsCreated: 1, views: 20)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        karma.text = String(user.karma)
        age.text = String(user.age)
        views.text = String(user.views)
        crumbsCreated.text = String(user.postsCreated)
    }
    

    @IBOutlet weak var karma: UILabel!
    
    @IBOutlet weak var crumbsCreated: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var age: UILabel!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
