//
//  UploadConfigViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class UploadConfigViewController: NSViewController {

    @objc var uploader: Uploader!
    @IBOutlet weak var binaryPath: NSTextField!
    var parentVC: DocumentViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.binaryPath.stringValue = self.uploader.binaryURL.relativePath
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
        NotificationCenter.default.post(name: Notification.Name.uploadingCancelled, object: self)
        self.dismiss(self)
    }
    
    @IBAction func okAction(_ sender: Any) {
        if self.uploader.serialController.serialPort == nil {
            _ = showAlertWindow(with: NSLocalizedString("Please choose a serial port!", comment: "Please choose a serial port!"))
            return
        }
        if let serialPortName = self.uploader.serialController.serialPort?.name {
            self.parentVC.serialPortStateLabel.stringValue = "\(parentVC.project!.chipType.rawValue) at /dev/cu.\(serialPortName)"
        }
        self.dismiss(self)
        NotificationCenter.default.post(name: NSNotification.Name.timeForNextUploadStage, object: self)
        
    }
}
