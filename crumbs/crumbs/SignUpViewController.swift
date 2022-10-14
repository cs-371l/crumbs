//
//  SignUpViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/14/22.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    let datePicker = UIDatePicker()
    override func viewDidLoad() {
        super.viewDidLoad()

        // createDatePicker()
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        
        toolbar.setItems([doneButton], animated: true)
        
        dateOfBirthTextField.inputAccessoryView = toolbar
        dateOfBirthTextField.inputView = datePicker
    }

}
