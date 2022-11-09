//
//  AboutViewController.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import UIKit

class AboutViewController: UIViewController {

    var user : User!
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.karmaNum.text = String(getKarma())
        // TODO: Calculate and display age
        self.age.text = "1d"
        self.views.text = String(self.user.views)
        self.crumbsCreated.text = String(self.user.posts?.count ?? 0)
    }
    
    func getKarma() -> Int{
        var tmp = 0
        for p in posts{
            tmp += p.likeCount
        }
        return tmp
    }
    
    func refreshView() {
        self.karmaNum.text = String(getKarma())
        // TODO: Calculate and display age
        
        self.age.adjustsFontSizeToFitWidth = true
        self.age.minimumScaleFactor = 0.2
        self.age.text = user.dateJoined.timeAgoDisplay().replacingOccurrences(of: "ago", with: "")
        self.views.text = String(self.user.views)
        self.crumbsCreated.text = String(self.user.posts?.count ?? 0)
    }
    

    @IBOutlet weak var karma: UILabel!
    
    @IBOutlet weak var karmaNum: UILabel!
    @IBOutlet weak var crumbsCreated: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var age: UILabel!
}
