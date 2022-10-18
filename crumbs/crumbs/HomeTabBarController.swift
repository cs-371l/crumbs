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
        self.tabBar.barTintColor = UIColor.systemGray2
    }
}
