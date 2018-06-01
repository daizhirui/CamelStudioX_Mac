//
//  SerialMonitorWindowController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/6/1.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa
import ORSSerial

class SerialMonitorWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.becomeMain(_:)), name: NSWindow.didBecomeMainNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func becomeMain(_ sender: Any) {
        if let vc = self.contentViewController as? SerialMonitorViewController {
            if vc.serialController.serialPort == nil {
                if let recentPort = UserDefaults.standard.object(forKey: "recentSerialPort") as? String {
                    for port in vc.serialController.serialPortManager.availablePorts {
                        if port.name == recentPort {
                            vc.serialController.serialPort = port
                            vc.portBox.selectItem(withTitle: recentPort)
                        } // End of if port.name == recentPort
                    }
                } // End of if let recentPort =...
            }
        }
    }
}
