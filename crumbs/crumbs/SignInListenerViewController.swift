//
//  AuthStateListenerViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/31/22.
//

import UIKit
import FirebaseAuth

let HOME_TAB_BAR_CONTROLLER_IDENTIFIER = "HomeTabBarController"

class SignInListenerViewController: UIViewController {
    
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
                    if !success {
                        // TODO: handle failed sign in.
                        print("Initialization of user failed.")
                        return
                    }
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: HOME_TAB_BAR_CONTROLLER_IDENTIFIER)
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()
                })
            }
        }
    }

}
