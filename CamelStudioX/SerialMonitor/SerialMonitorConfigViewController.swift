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
    @IBOutlet weak var baudrateBox: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        guard let baudrateValue = self.parentVC.serialController.serialPort?.baudRate else { return }
        self.baudrateBox.selectItem(withTitle: "\(baudrateValue)")
    }
    @IBAction func baudrateBoxAction(_ sender: NSPopUpButton) {
        guard let baudrateString = sender.selectedItem?.title else { return }
        guard let baudrateValue = Int(baudrateString) else { return }
        self.parentVC.baudrateBox.selectItem(withTitle: baudrateString)
        self.parentVC.serialController.serialPort?.baudRate = NSNumber(value: baudrateValue)
    }
    
    @IBAction func okAction(_ sender: Any) {
        self.dismiss(self)
    }
}
