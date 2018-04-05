//
//  SerialMonitorConfigViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/4.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class SerialMonitorConfigViewController: NSViewController {
    
    @objc var parentVC: SerialMonitorViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func okAction(_ sender: Any) {
        self.dismiss(self)
    }
}
