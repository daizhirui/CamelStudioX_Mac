//
//  GetNameViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/4.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

enum ProjectFileOperantion {
    case rename
    case newFolder
    case newFile
}

class GetNameViewController: NSViewController {

    var parentVC: DocumentViewController!
    var fileOperation: ProjectFileOperantion!
    var parentNode: FileWrapper!
    var node: FileWrapper!
    var childNames = [String]()
    
    @IBOutlet weak var operationLabel: NSTextField!
    @IBOutlet weak var nameBox: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch self.fileOperation {
        case .rename:
            self.operationLabel.stringValue = NSLocalizedString("Rename to:", comment: "Rename to:")    // Set Window title
            if let fileName = self.node.preferredFilename { // Load file name
                self.nameBox.stringValue = fileName
            }
        case .newFolder:
            self.operationLabel.stringValue = NSLocalizedString("Folder Name:", comment: "Folder Name:")
        case .newFile:
            self.operationLabel.stringValue = NSLocalizedString("File Name:", comment: "File Name:")
        default:
            self.operationLabel.stringValue = NSLocalizedString("ERROR", comment: "ERROR")
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        switch self.fileOperation {
        case .rename:
            self.view.window?.title = "Rename"
        case .newFolder:
            self.view.window?.title = "New Folder"
        case .newFile:
            self.view.window?.title = "New File"
        default:
            self.view.window?.title = "ERROR"
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(self)
    }
    @IBAction func okAction(_ sender: Any) {
        // check if name is provided
        if self.nameBox.stringValue == "" {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Name is empty!", comment: "Name is empty!"))
            return
        } else if self.childNames.contains(self.nameBox.stringValue) {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("The name already exists!", comment: "The name already exists!"))
            return
        }
        // start to operate
        var newFileWrapper: FileWrapper
        switch self.fileOperation {
        case .rename:
            newFileWrapper = self.node.copy() as! FileWrapper
            parentNode.removeFileWrapper(node)
        case .newFolder:
            newFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
        case .newFile:
            newFileWrapper = FileWrapper(regularFileWithContents: Data())
        default:
            return
        }
        // Save FileWrapper Operation
        newFileWrapper.preferredFilename = self.nameBox.stringValue
        if self.fileOperation == .rename {
            self.parentNode.addFileWrapper(newFileWrapper)
        } else {
            self.node.addFileWrapper(newFileWrapper)
        }
        // Save the project
        parentVC.isOperatingFile = true
        NSDocumentController.shared.currentDocument?.save(self)
        self.parentVC.updateProjectInspector()
        self.dismiss(self)
    }
}
