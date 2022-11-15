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
        self.selectedIndex = DISCOVER_INDEX
    }
}
