//
//  UploadConfigViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import ORSSerial

class UploadConfigViewController: NSViewController {

    @objc var uploader: Uploader!
    @IBOutlet weak var portBox: NSPopUpButton!
    @IBOutlet weak var binaryPath: NSTextField!
    var parentVC: DocumentViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.binaryPath.stringValue = self.uploader.binaryURL.relativePath
    }
    
    override func viewDidAppear() {
        if let portName = self.uploader.recentSerialPort?.name {
            self.portBox.selectItem(withTitle: portName)
            self.uploader.serialPort = self.uploader.recentSerialPort
        } else if let portName = UserDefaults.standard.object(forKey: "recentSerialPort") as? String {
            for possiblePort in self.uploader.serialPortManager.availablePorts {
                if possiblePort.name == portName {
                    self.portBox.selectItem(withTitle: portName)
                    self.uploader.serialPort = possiblePort
                }
            }
        }
        self.uploader.serialPort?.baudRate = 9600
    }
    
    @IBAction func selectBinary(_ sender: Any) {
        // 创建面板
        let openFileDlg = NSOpenPanel()
        openFileDlg.title = NSLocalizedString("Select a binary", comment: "Select a binary")
        openFileDlg.directoryURL = self.uploader.binaryURL.deletingLastPathComponent()
        openFileDlg.canChooseFiles = true
        openFileDlg.canChooseDirectories = false
        openFileDlg.allowsMultipleSelection = false
        openFileDlg.allowedFileTypes = ["bin"]
        // 启动面板
        // completionHandler 为面板点击 OK 时执行的操作，此处为打开操作
        openFileDlg.begin(completionHandler: { [weak self] result in
            if (result.rawValue == NSApplication.ModalResponse.OK.rawValue) {
                let fileURLs = openFileDlg.urls
                for url: URL in fileURLs {
                    self?.uploader.binaryURL = url
                    self?.binaryPath.stringValue = url.relativePath
                }
            }
        })
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.uploadingCancelled, object: self.parentVC)
        self.dismiss(self)
    }
    
    @IBAction func okAction(_ sender: Any) {
        if self.uploader.serialPort == nil {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Please choose a serial port!", comment: "Please choose a serial port!"))
            return
        }
        if let serialPort = self.uploader.serialPort {
            self.parentVC.serialPortStateLabel.stringValue = "\(parentVC.project!.chipType.rawValue) at /dev/cu.\(serialPort.name)"
            UserDefaults.standard.set(serialPort.name as Any, forKey: "recentSerialPort")
        }
        self.dismiss(self)
        self.uploader.uploadConfigReady = true
        self.uploader.startUpload()
        self.uploader.uploadStageControl(nil)
    }
}
