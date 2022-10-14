//
//  ViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/9/22.
//

import UIKit

class ViewController: UIViewController {
    let segueIdentifier = "PostCreationSegueIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func createPostButtonPressed(_ sender: Any) {
        print("hi")
        performSegue(withIdentifier: segueIdentifier, sender: self)
        print("done")
    }
}

