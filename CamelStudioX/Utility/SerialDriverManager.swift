//
//  SerialDriverManager.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/5/31.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

class SerialDriverManager: NSObject {
    
    static func chooseInstaller() {
        let alert = NSAlert()
        // add OK button
        alert.addButton(withTitle: "CH340")
        alert.addButton(withTitle: "PL2303")
        alert.addButton(withTitle: "Cancel")
        // set the alert title
        alert.messageText = NSLocalizedString("Alert", comment: "NSAlert Title")
        alert.informativeText = NSLocalizedString("Please choose the driver", comment: "Please choose the driver")
        alert.alertStyle = .critical

        // Search Main Window
        let appDelegate = NSApp.delegate as! AppDelegate
        var window: NSWindow!
        if let mainWindow = NSApp.mainWindow {
            window = mainWindow
        } else {
            appDelegate.showWelcomeWindow(self)
            window = WelcomeWindow.windowOnShow
        }

        alert.beginSheetModal(for: window, completionHandler: { returnCode in
            myDebug(returnCode)
            if returnCode.rawValue == 1000 {
                if let path = Bundle.main.url(forResource: "ch34x", withExtension: "pkg")?.relativePath {
                    NSWorkspace.shared.openFile(path)
                } else {
                    _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("ch34x.pkg lost!", comment: "ch34x.pkg lost!"))
                }
            }
            if returnCode.rawValue == 1001 {
                if let path = Bundle.main.url(forResource: "pl2303", withExtension: "pkg")?.relativePath {
                    NSWorkspace.shared.openFile(path)
                } else {
                    _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("pl2303.pkg lost!", comment: "pl2303.pkg lost!"))
                }
            }
        })
    }

    static var pl2303DriverDetected: Bool {
        get {
            return FileManager.default.fileExists(atPath: "/Library/Extensions/ProlificUsbSerial.kext")
        }
    }
    
    static var osx_ch341DriverDetected: Bool {
        get {
            return FileManager.default.fileExists(atPath: "/Library/Extensions/osx-ch341.kext")
        }
    }
    
    static var osx_pl2303DriverDetected: Bool {
        get {
            return FileManager.default.fileExists(atPath: "/Library/Extensions/osx-pl2303.kext")
        }
    }
    
    static var serialDriverDetected: Bool {
        get {
            return SerialDriverManager.pl2303DriverDetected||SerialDriverManager.osx_ch341DriverDetected||SerialDriverManager.osx_pl2303DriverDetected
        }
    }
}
