//
//  AlertViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/5/24.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

class AlertViewController: NSViewController {

    @IBOutlet weak var informativeText: NSTextField!
    
    var needDontShowAgain = false
    var dontShowAgainKey: String = ""
    @IBOutlet weak var dontShowAgain: NSButton!
    
    var completedHandler: (()->Void)?
    
    @IBOutlet weak var cancelButton: NSButton!
    var needCancelButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myDebug("AlerViewController \(self) is loaded.\n")
    }
    
    override func viewWillAppear() {
        if self.needCancelButton {
            self.view.window?.styleMask.insert(NSWindow.StyleMask.closable)
        } else {
            self.view.window?.styleMask.remove(NSWindow.StyleMask.closable)
        }
        
        self.dontShowAgain.isHidden = !self.needDontShowAgain
        self.cancelButton.isHidden = !self.needCancelButton
    }
    
    @IBAction func closeAlert(_ sender: Any) {
        if !self.dontShowAgain.isHidden && self.dontShowAgainKey.count > 0 {
            if self.dontShowAgain.state == .on {
                UserDefaults.standard.set(true as Any, forKey: "Don't Show Alert: \(self.dontShowAgainKey)")
            } else {
                UserDefaults.standard.set(false as Any, forKey: "Don't Show Alert: \(self.dontShowAgainKey)")
            }
        }
        self.view.window?.close()
        NSApp.abortModal()
        if let button = sender as? NSButton {
            if button.title == "OK" {
                self.completedHandler?()
            }
        }
    }
}
