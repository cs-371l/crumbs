//
//  HomeTabBarController.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    private final let DISCOVER_INDEX = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.selectedIndex = DISCOVER_INDEX
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
