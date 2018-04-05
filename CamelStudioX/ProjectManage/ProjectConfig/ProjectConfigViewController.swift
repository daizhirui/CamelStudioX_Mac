//
//  ProjectConfigViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class ProjectConfigViewController: NSViewController {

    @IBOutlet weak var projectPath: NSTextField!
    @IBOutlet weak var targetName: NSTextField!
    @IBOutlet weak var targetAddress: NSTextField!
    @IBOutlet weak var dataAddress: NSTextField!
    @IBOutlet weak var rodataAddress: NSTextField!
    @IBOutlet weak var officialLibrary: NSTextField!
    @IBOutlet weak var customLibrary: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // show the project config
        if let project = (NSDocumentController.shared.currentDocument as? Document)?.project {
            self.projectPath.stringValue = project.projectURL?.relativePath ?? ""
            self.targetName.stringValue = project.targetName
            self.targetAddress.stringValue = project.targetAddress
            self.dataAddress.stringValue = project.dataAddress
            self.rodataAddress.stringValue = project.rodataAddress
            self.officialLibrary.stringValue = project.library.joined(separator: " ")
            self.customLibrary.stringValue = project.customLibrary.joined(separator: " ")
        }
    }
    
    @IBAction func showProject(_ sender: Any) {
        if let projectURL = (NSDocumentController.shared.currentDocument as? Document)?.project.projectURL {
            NSWorkspace.shared.activateFileViewerSelecting([projectURL])
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(self)
    }
    
    /**
     Check and store project config
    */
    @IBAction func okAction(_ sender: Any) {
        if let project = (NSDocumentController.shared.currentDocument as? Document)?.project {
            // store targetName
            if self.targetName.stringValue.count > 0 {
                project.targetName = self.targetName.stringValue
            } else {
                _ = showAlertWindow(with: NSLocalizedString("Target Name is empty!", comment: "Target Name is empty!"))
                return
            }
            // store targetAddress
            if self.targetAddress.stringValue.count > 0 {
                project.targetAddress = self.targetAddress.stringValue
            } else {
                _ = showAlertWindow(with: NSLocalizedString("Target Address is empty!", comment: "Target Address is empty!"))
                return
            }
            // store dataAddress
            if self.dataAddress.stringValue.count > 0 {
                project.dataAddress = self.dataAddress.stringValue
            } else {
                _ = showAlertWindow(with: NSLocalizedString("Data Address is empty!", comment: "Data Address is empty!"))
                return
            }
            // store rodataAddress
            project.rodataAddress = self.rodataAddress.stringValue
            // store officialLibrary
            project.library = self.officialLibrary.stringValue.components(separatedBy: .whitespaces)
            // store customLibrary
            project.customLibrary = self.customLibrary.stringValue.components(separatedBy: .whitespaces)
            // project config completed, write to disk
            NSDocumentController.shared.currentDocument?.save(self)
            self.dismiss(self)
        }
    }
}
