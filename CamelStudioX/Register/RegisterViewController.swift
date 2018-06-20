//
//  RegisterViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/6/20.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

class RegisterViewController: NSViewController {

    @IBOutlet weak var userNameTextField: NSTextField!
    @IBOutlet weak var emailTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = UserDefaults.standard.object(forKey: "UserName") as? String {
            self.userNameTextField.stringValue = userName
        } else {
            self.userNameTextField.stringValue = NSUserName()
        }
        
        if let userMailAddress = UserDefaults.standard.object(forKey: "UserMailAddress") as? String {
            self.emailTextField.stringValue = userMailAddress
        } else {
            self.userNameTextField.stringValue = NSUserName()
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if !AppDelegate.shared.reRegister {
            NSApp.terminate(self)
        } else {
            self.closeRegisterWindow()
        }
    }
    
    @IBAction func onOK(_ sender: Any) {
        if userNameTextField.stringValue.count == 0 {
            _ = InfoAndAlert.shared.showAlertWindow(with: "User Name is empty!")
            return
        }
        if  emailTextField.stringValue.count == 0 {
            _ = InfoAndAlert.shared.showAlertWindow(with: "E-Mail Address is empty!")
            return
        }
        
        let userID = "\(self.userNameTextField.stringValue.hashValue)"
        let userName = self.userNameTextField.stringValue
        let emailAddress = self.emailTextField.stringValue
        
        UserDefaults.standard.set(userID, forKey: "UserID")
        UserDefaults.standard.set(userName, forKey: "UserName")
        UserDefaults.standard.set(emailAddress, forKey: "UserMailAddress")
        
        AppDelegate.shared.hockeyManager?.setUserID(userID)
        AppDelegate.shared.hockeyManager?.setUserName(userName)
        AppDelegate.shared.hockeyManager?.setUserEmail(emailAddress)
        
        self.closeRegisterWindow()
    }
    
    func closeRegisterWindow() {
        AppDelegate.shared.reRegister = false
        NSApp.abortModal()
        self.view.window?.close()
    }
}
