//
//  ErrorMessage.swift
//  crumbs
//
//  Created by Kevin Li on 11/7/22.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlert(title: String, message: String, completion: @escaping ((UIAlertAction) -> Void) = {_ in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: completion))
        
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.async {
            self.removeSpinner()
        }
    }
}
