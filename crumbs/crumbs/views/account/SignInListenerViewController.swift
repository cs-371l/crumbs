//
//  AuthStateListenerViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/31/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

let HOME_TAB_BAR_CONTROLLER_IDENTIFIER = "HomeTabBarController"

class SignInListenerViewController: UIViewController, UINavigationControllerDelegate {
    
    var authListener: AuthStateDidChangeListenerHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        listenToSignInChange()
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(self.authListener)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if !(viewController is LoginViewController) {
            Auth.auth().removeStateDidChangeListener(self.authListener)
        } else {
            listenToSignInChange()
        }
    }
    
    func listenToSignInChange() {
        self.authListener = Auth.auth().addStateDidChangeListener() {
            auth, user in
            guard user != nil else {
                return
            }

            self.showSpinner(onView: self.view)
            
            let db = Firestore.firestore()
            db.collection("users").document(user!.uid).getDocument() {
                (snapshot, err) in
                if let err = err {
                    self.showErrorAlert(title: "Error", message: "Unable to sign in.")
                    print(err.localizedDescription)
                    return
                } else {
                    CUR_USER = User(snapshot: snapshot!)
                    
                    CUR_USER.getPosts {
                        success, posts in
                        if !success {
                            self.showErrorAlert(title: "Error", message: "Unable to load profile.")
                            return
                        }
                        DispatchQueue.main.async {
                            self.removeSpinner()
                        }
                        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: HOME_TAB_BAR_CONTROLLER_IDENTIFIER)
                        self.view.window?.rootViewController = homeViewController
                        self.view.window?.makeKeyAndVisible()
                    }

                }
            }
        }
    }

}
