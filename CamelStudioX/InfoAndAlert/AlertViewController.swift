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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func closeAlert(_ sender: Any) {
        self.view.window?.close()
        NSApp.abortModal()
    }
}
