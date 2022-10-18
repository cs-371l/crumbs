//
//  ViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/9/22.
//

import UIKit

class ViewController: UIViewController {
    
    let signupSegueIdentifier = "SignUpPageSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpPageButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: signupSegueIdentifier, sender: self)
    }
    
}

