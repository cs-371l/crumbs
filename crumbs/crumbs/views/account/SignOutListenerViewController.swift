//
//  AuthStateListenerViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/31/22.
//

import UIKit
import FirebaseAuth

class SignOutListenerViewController: UIViewController, UINavigationControllerDelegate {
    
    private final let LOGIN_VIEW_IDENTIFIER = "LoginViewController"
    
    var authListener: AuthStateDidChangeListenerHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        listenToSignOutChange()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        listenToSignOutChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(self.authListener)
    }
    
    func listenToSignOutChange() {
        self.authListener = Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user == nil {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: self.LOGIN_VIEW_IDENTIFIER)
                self.view.window?.rootViewController = loginViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }

}
