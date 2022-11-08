//
//  AppDelegate.swift
//  crumbs
//
//  Created by Tristan Blake on 10/9/22.
//

import UIKit
import FirebaseCore

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func timeFromNow() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func getColorFromDateAgo() -> UIColor {
        let diff = Date().timeIntervalSince(self)
        
        let lowBound: TimeInterval = 60.0 * 60.0
        let highBound: TimeInterval = 60.0 * 60.0 * 24.0 * 12.0
        
        print(diff)
        if diff < lowBound {
            return UIColor.systemGreen
        }
        
        if diff < highBound {
            return UIColor.orange
        }
        
        return UIColor.magenta
        
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Framework for scrolling keyboard
        IQKeyboardManager.shared.enable = true
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

