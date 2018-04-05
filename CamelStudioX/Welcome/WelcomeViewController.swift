//
//  WelcomeViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/1.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class WelcomeViewController: NSViewController {

    static var welcomeViewDidShowed = false
    // ************ Record and control the appearance ***************
    static var shouldShow: Bool {
        if AppDelegate.isRestoring {
            return false
        } else {
            // Application is not restoring
            return DocumentViewController.openedDocumentViewController <= 0 && !welcomeViewDidShowed
        }
    }
    @IBOutlet var welcomeView: NSView!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var recentProjectTable: NSTableView!
    var selectedProjectNameTextField: NSTextField!
    var selectedProjectURLTextField: NSTextField!
    @IBOutlet weak var versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the round corners
        self.welcomeView.wantsLayer = true
        self.welcomeView.layer?.backgroundColor = NSColor.white.cgColor
        self.welcomeView.layer?.cornerRadius = 10.0
        // Set the version label
        let version: Any = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build: Any = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        self.versionLabel.stringValue = "Version \(version) (Build \(build))"
        // Set the background color of left part white
        self.leftView.wantsLayer = true
        self.leftView.layer?.backgroundColor = NSColor.white.cgColor
        // Set the looking of the recent project table
        self.recentProjectTable.selectionHighlightStyle = .sourceList
        // Set the double click action
        self.recentProjectTable.doubleAction = #selector(self.doubleClickRecentProject)
        // Load the recent project table
        self.recentProjectTable.delegate = self
        self.recentProjectTable.dataSource = self
        self.recentProjectTable.reloadData()
        let area = NSTrackingArea(rect: self.leftView.frame, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        self.view.addTrackingArea(area)
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.closeButton.isHidden = false
    }
    
    override func mouseExited(with event: NSEvent) {
        self.closeButton.isHidden = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        WelcomeViewController.welcomeViewDidShowed = true
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        WelcomeViewController.welcomeViewDidShowed = false
    }
    // MARK: action
    @IBAction func closeWelcomeWindow(_ sender: Any) {
        self.view.window?.close()
    }
    
    /**
     Create a new project
    */
    @IBAction func createNewProject(_ sender: Any) {
        NSDocumentController.shared.newDocument(self)
        self.closeWelcomeWindow(self)
    }
    
    /**
     Choose and open a project
    */
    @IBAction func openProject(_ sender: Any) {
        NSDocumentController.shared.openDocument(self)
        self.closeWelcomeWindow(self)
    }
    
    /**
     Open project from recent project list
    */
    @objc func doubleClickRecentProject() {
        if let stackView = self.getSelectedCellView()?.subviews[0] as? NSStackView {
            if let urlLabel = stackView.subviews[1] as? NSTextField {
                NSDocumentController.shared.openDocument(withContentsOf: URL(fileURLWithPath: urlLabel.stringValue), display: true, completionHandler: { _,_,_ in })
                self.closeWelcomeWindow(self)
            }
        }
    }
    /*
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let storyBoard = NSStoryboard.init(name: NSStoryboard.Name("Welcome"), bundle: nil)
    }*/
    
}
// MARK: NSTableViewDataSource
extension WelcomeViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return NSDocumentController.shared.recentDocumentURLs.count
    }
    
    func getSelectedCellView() -> NSView? {
        let row = self.recentProjectTable.selectedRow
        let column = self.recentProjectTable.selectedColumn
        print("row = \(row), column = \(column)")
        if row >= 0 {
            return self.recentProjectTable.view(atColumn: column, row: row, makeIfNecessary: false)
        } else {
            return nil
        }
        
    }
}
// MARK: NSTableViewDelegate
extension WelcomeViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let urls = NSDocumentController.shared.recentDocumentURLs
        // 表格列的标识
        let key = (tableColumn?.identifier)!
        // 单元格数据
        let value = urls[row]
        // 根据表格列的标识，创建单元视图
        let view = tableView.makeView(withIdentifier: key, owner: self)
        let subviews = view?.subviews
        if (subviews?.count)! <= 0 {
            return nil
        }
        // 存储此单元格视图
        if let stackView = subviews?[0] as? NSStackView {
            if let projectNameLabel = stackView.subviews[0] as? NSTextField {
                projectNameLabel.stringValue = value.deletingPathExtension().lastPathComponent
            }
            if let projectURLLabel = stackView.subviews[1] as? NSTextField {
                projectURLLabel.stringValue = value.relativePath
            }
        }
        let projectImage = subviews?[1] as? NSImageView
        if value.pathExtension == "cms" {
            projectImage?.image = #imageLiteral(resourceName: "cms.png")
        }
        if value.pathExtension == "cmsx" {
            projectImage?.image = #imageLiteral(resourceName: "cmsx.png")
        }
        if value.pathExtension == "cmsproj" {
            projectImage?.image = #imageLiteral(resourceName: "cmsproj.png")
        }
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        self.selectedProjectNameTextField?.textColor = NSColor.black
        self.selectedProjectURLTextField?.textColor = NSColor.black
        if let stackView = self.getSelectedCellView()?.subviews[0] as? NSStackView {
            self.selectedProjectNameTextField = stackView.arrangedSubviews[0] as? NSTextField
            self.selectedProjectURLTextField = stackView.arrangedSubviews[1] as? NSTextField
            self.selectedProjectNameTextField?.textColor = NSColor.white
            self.selectedProjectURLTextField?.textColor = NSColor.white
        }
    }
    
}
/*
extension WelcomeViewController: NSSplitViewDelegate {
    func splitView(_ splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        return false
    }
    func splitView(_ splitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return 440
    }
}*/

