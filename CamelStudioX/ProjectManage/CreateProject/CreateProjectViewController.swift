//
//  CreateProjectViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/2.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class CreateProjectViewController: NSViewController {
    
    @IBOutlet weak var projectName: NSTextField!
    @IBOutlet weak var author: NSTextField!
    @IBOutlet weak var targetName: NSTextField!
    @IBOutlet weak var targetAddress: NSTextField!
    @IBOutlet weak var dataAddress: NSTextField!
    @IBOutlet weak var rodataAddress: NSTextField!
    @IBOutlet weak var officialLibrary: NSTextField!
    @IBOutlet weak var chipType: NSPopUpButton!
    @IBOutlet weak var okButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup some items
        self.author.stringValue = NSUserName()
        self.targetAddress.stringValue = "10000000"
        self.dataAddress.stringValue = "01000010"
        self.chipType.selectItem(at: 0)
        self.okButton.isEnabled = false
        // setup text detect
        self.projectName.delegate = self
        self.targetName.delegate = self
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(self)
        NSDocumentController.shared.currentDocument?.windowControllers[0].close()
    }
    
    @IBAction func okAction(_ sender: Any) {
        if let document = NSDocumentController.shared.currentDocument as? Document {
            document.project.projectName = self.projectName.stringValue
            document.project.author = self.author.stringValue
            document.project.targetName = self.targetName.stringValue
            document.project.dataAddress = self.dataAddress.stringValue
            document.project.rodataAddress = self.rodataAddress.stringValue
            document.project.library = self.officialLibrary.stringValue.components(separatedBy: .whitespaces)
            let cFileContent =
            """
            /***************************************************
            Project: \(document.project.projectName)
            File Name: \(document.project.targetName).c
            Author: \(NSUserName())
            Date: \(Date().description(with: Locale.current))
            Copyright © \(Calendar.current.component(.year, from: Date())) \(NSUserName()). All rights reserved.
            ****************************************************/
            
            // Add your header files here
            #include "mcu.h"
            
            // This is the interrupt function for user
            void user_interrupt() {
            
            }
            
            // This is the main function
            void main() {
            \t// set some varibles here, like:
            \t// int a = 1
            
            \t// setup modules you need here, like:
            \t// RT_UART1_ON()    // This function requires "UART1.h"
            
            \t// run the main loop
            \twhile(1) {
            
            \t}
            }
            """
            let data = cFileContent.data(using: .utf8)!
            let sampleFile = FileWrapper(regularFileWithContents: data)
            sampleFile.preferredFilename = "\(document.project.targetName).c"
            document.project.filewrappers?.addFileWrapper(sampleFile)
            self.dismiss(self)
            document.displayName = self.projectName.stringValue
            document.save(self)
        }
    }
}

extension CreateProjectViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        self.okButton.isEnabled = (self.targetName.stringValue.count > 0 && self.projectName.stringValue.count > 0)
    }
}
