//
//  AuthStateListenerViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/31/22.
//

import UIKit
import FirebaseAuth

class SignInListenerViewController: UIViewController {
    
    private final let HOME_TAB_BAR_CONTROLLER_IDENTIFIER = "HomeTabBarController"
    
    var authListener: AuthStateDidChangeListenerHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        listenToSignInChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(self.authListener)
    }
    
    func listenToSignInChange() {
        self.authListener = Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                self.showSpinner(onView: self.view)
                
                CUR_USER = User(firebaseUser: user!, callback: {
                    success in
                    self.removeSpinner()
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: self.HOME_TAB_BAR_CONTROLLER_IDENTIFIER)
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()
                })
            }
        }
    }

}
