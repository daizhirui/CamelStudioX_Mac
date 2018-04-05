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
    var grandNode: FileWrapper!
    var parentNode: FileWrapper!
    var parentNames = [String]()
    var childNames = [String]()
    
    @IBOutlet weak var operationLabel: NSTextField!
    @IBOutlet weak var nameBox: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch self.fileOperation {
        case .rename:
            self.operationLabel.stringValue = NSLocalizedString("Rename to:", comment: "Rename to:")
        case .newFolder:
            self.operationLabel.stringValue = NSLocalizedString("Folder Name:", comment: "Folder Name:")
        case .newFile:
            self.operationLabel.stringValue = NSLocalizedString("File Name:", comment: "File Name:")
        default:
            self.operationLabel.stringValue = NSLocalizedString("ERROR", comment: "ERROR")
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(self)
    }
    @IBAction func okAction(_ sender: Any) {
        // check if name is provided
        if self.nameBox.stringValue == "" {
            _ = showAlertWindow(with: NSLocalizedString("Name is empty!", comment: "Name is empty!"))
            return
        }
        // start to operate
        switch self.fileOperation {
        case .rename:
            if self.parentNames.contains(self.nameBox.stringValue) {
                _ = showAlertWindow(with: NSLocalizedString("The name already exists!", comment: "The name already exists!"))
                return
            } else {
                let fileWrapper = self.parentNode.copy() as! FileWrapper
                fileWrapper.preferredFilename = self.nameBox.stringValue
                grandNode.removeFileWrapper(parentNode)
                grandNode.addFileWrapper(fileWrapper)
            }
        case .newFolder:
            if self.childNames.contains(self.nameBox.stringValue) {
                _ = showAlertWindow(with: NSLocalizedString("The name already exists!", comment: "The name already exists!"))
                return
            } else {
                let folderFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
                folderFileWrapper.preferredFilename = self.nameBox.stringValue
                self.parentNode.addFileWrapper(folderFileWrapper)
            }
        case .newFile:
            if self.childNames.contains(self.nameBox.stringValue) {
                _ = showAlertWindow(with: NSLocalizedString("The name already exists!", comment: "The name already exists!"))
                return
            } else {
                let fileWrapper = FileWrapper(regularFileWithContents: Data())
                fileWrapper.preferredFilename = self.nameBox.stringValue
                self.parentNode.addFileWrapper(fileWrapper)
            }
        default:
            return
        }
        // save
        parentVC.isOperatingFile = true
        NSDocumentController.shared.currentDocument?.save(self)
        self.parentVC.updateProjectInspector()
        self.dismiss(self)
    }
}
