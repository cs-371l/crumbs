//
//  SettingsViewController.swift
//  crumbs
//
//  Created by Tristan Blake on 10/18/22.
//

import UIKit
import FirebaseAuth

let settings:[String] = ["Notifications", "Dark Mode", "App Version"]

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
}

class SettingsViewController: SignOutListenerViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingsTable: UITableView!
    
    private final let SETTING_CELL_IDENTIFIER = "SettingCellIdentifier"
    private final let LOGOUT_TO_LOGIN_SEGUE_IDENTIFIER = "LogoutToLoginSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsTable.delegate = self
        self.settingsTable.dataSource = self
        self.settingsTable.allowsSelection = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SETTING_CELL_IDENTIFIER, for: indexPath) as! SettingsTableViewCell
        let row = indexPath.row
        let settingName = settings[row]
        cell.settingLabel.text = settingName
        if settingName == "App Version" {
            cell.settingSwitch.isHidden = true
            cell.settingLabel.textColor = UIColor.gray
            cell.settingLabel.text = "\(settingName) 1.0a"
        }
        if settingName == "Dark Mode" {
            let defaults = UserDefaults.standard
            let isDark = defaults.bool(forKey: "Dark")
            cell.settingSwitch.setOn(isDark, animated: true)
            cell.settingSwitch.addTarget(self, action: #selector(self.themeSwitched), for: .valueChanged)
        }
        return cell
    }
    
    @objc func themeSwitched(darkSwitch: UISwitch!) {
        let defaults = UserDefaults.standard
        if darkSwitch.isOn {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .dark
            defaults.set(true, forKey: "Dark")
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .light
            defaults.set(false, forKey: "Dark")
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
