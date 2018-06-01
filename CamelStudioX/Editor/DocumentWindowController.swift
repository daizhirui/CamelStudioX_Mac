//
//  DocumentWindowController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/2.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class DocumentWindowController: NSWindowController {
    
    lazy var viewController = {
        return self.window?.contentViewController as! DocumentViewController
    }()
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressInfo: NSTextField!
    @IBOutlet weak var loadToBoardButton: NSButton!
    @IBOutlet weak var loadToBoardButtonInTouchbar: NSButton!
    @IBOutlet weak var serialMonitorButton: NSButton!
    @IBOutlet weak var serialMonitorButtonInTouchbar: NSButton!
    @IBOutlet weak var projectConfigButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // prepare upload config view controller
        self.uploadConfigViewController.uploader = self.uploader
        self.uploader.viewController = self.viewController
        //NSUserNotificationCenter.default.delegate = self
        // addObservers
        self.addObserversForUpload()
        NotificationCenter.default.addObserver(self, selector: #selector(self.lostFocusAction(_:)), name: NSWindow.didResignMainNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getFocusAction(_:)), name: NSWindow.didBecomeMainNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resizeWindow(_:)), name: NSWindow.didResizeNotification, object: nil)
        // check if a tab window is required
        if AppDelegate.isRequiringNewTab {
            self.addWindowAsTab()
            AppDelegate.isRequiringNewTab = false
        }
        self.progressIndicator.isHidden = true
    }
    //****************** About Window Resize ******************************
    @objc func resizeWindow(_ aNotification: Notification) {
        let width = self.viewController.editAreaScrollView.frame.width + 20
        let height = self.viewController.editAreaScrollView.frame.height
        let x = self.viewController.editAreaScrollView.contentView.frame.origin.x
        let y = self.viewController.editAreaScrollView.contentView.frame.origin.y
        let newFrame = NSRect(x: x, y: y, width: width, height: height)
        self.viewController.editAreaScrollView.contentView.frame = newFrame
    }
    //****************** About Project Inspector **************************
    /// Change text color when window becomes unmain
    @objc func lostFocusAction(_ aNotification: Notification) {
        self.viewController.lastSelectedItem?.textColor = NSColor.darkGray
    }
    /// Change text color and update project inspector when window becomes main
    @objc func getFocusAction(_ aNotification: Notification) {
        self.viewController.lastSelectedItem?.textColor = NSColor.white
        self.viewController.updateProjectInspector()
    }
    //************************ About Side Panel ***************************
    /// open or close side panel
    var sidePanelWidth: CGFloat = 0
    func toggelSidePanel() {
        if let viewController = self.contentViewController as? DocumentViewController {
            // get splitView
            if let splitView = viewController.splitView {
                // get side panel view
                let leftView = splitView.subviews[0]
                // check if it is hidden
                if splitView.isSubviewCollapsed(leftView) {
                    // is hidden
                    splitView.setPosition(self.sidePanelWidth, ofDividerAt: 0)
                    leftView.isHidden = false
                } else {
                    // not hidden
                    self.sidePanelWidth = leftView.frame.size.width
                    splitView.setPosition(0, ofDividerAt: 0)
                    leftView.isHidden = true
                }
                splitView.adjustSubviews()
                // update Show SidePanel menu's state
                if let mainMenuItems = NSApp.mainMenu?.items {
                    for mainItem in mainMenuItems {
                        if mainItem.title == NSLocalizedString("View", comment: "View") {
                            if let viewMenuItems = mainItem.submenu?.items {
                                for viewItem in viewMenuItems {
                                    if viewItem.title == NSLocalizedString("Show SidePanel", comment: "Show SidePanel") {
                                        viewItem.state = (leftView.isHidden == true ? .off : .on)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func toggelBuildMessagePanel() {
        if let viewController = self.contentViewController as? DocumentViewController {
            // get splitView
            if let splitView = viewController.editAreaSplitView {
                // get side panel view
                let bottomView = splitView.subviews[1]
                // check if it is hidden
                if splitView.isSubviewCollapsed(bottomView) {
                    // is hidden
                    splitView.setPosition(self.sidePanelWidth, ofDividerAt: 0)
                    bottomView.isHidden = false
                } else {
                    // not hidden
                    self.sidePanelWidth = bottomView.frame.size.width
                    splitView.setPosition(0, ofDividerAt: 0)
                    bottomView.isHidden = true
                }
                splitView.adjustSubviews()
                // update Show SidePanel menu's state
                if let mainMenuItems = NSApp.mainMenu?.items {
                    for mainItem in mainMenuItems {
                        if mainItem.title == NSLocalizedString("View", comment: "View") {
                            if let viewMenuItems = mainItem.submenu?.items {
                                for viewItem in viewMenuItems {
                                    if viewItem.title == NSLocalizedString("Show Build Message Panel", comment: "Show Build Message Panel") {
                                        viewItem.state = (bottomView.isHidden == true ? .off : .on)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    @IBAction func toggelPanel(_ sender: Any) {
        if let toolBarItem = sender as? NSButton {
            if toolBarItem.title == "Side Panel" {
                self.toggelSidePanel()
            }
            if toolBarItem.title == "Build Message" {
                self.toggelBuildMessagePanel()
            }
        } // end of if let toolBarItem
        else if let menuItem = sender as? NSMenuItem {
            if menuItem.title == "Show SidePanel" {
                self.toggelSidePanel()
            } else if menuItem.title == "Show Build Message Panel" {
                self.toggelBuildMessagePanel()
            }
            menuItem.state = (menuItem.state == .on ? .off : .on)
        }
    }
    // ******************** Project Config Menu Action ****************
    @IBAction func openProjectConfig(_ sender: Any) {
        self.projectConfigButton.performClick(self)
    }
    // ******************* Generate Makefile ********************
    @IBAction func generateMakefile(_ sender: Any) {
        // Save the modification at first
        NSDocumentController.shared.currentDocument?.save(self)
        // get the project
        if let project = self.viewController.project {
            // Update project
            project.updateFileWrappers()
            project.updateSourceFiles()
            // Create a compiler
            let aCompiler = Compiler(forProject: project)
            // Generate makefile, if fails, exit
            _ = aCompiler.generateMakefile()
        }
    }
    func updateBuildResult(errorOutput: String) -> Bool {
        var compilerMessageViewController: CompilerMessageViewController?
        for controller in self.viewController.childViewControllers {
            if let vc = controller as? CompilerMessageViewController {
                compilerMessageViewController = vc
                break   // stop searching
            } else {
                compilerMessageViewController = nil
            }
        }
        if errorOutput.count > 0 {
            var warnning_count = 0
            var error_count = 0
            let attributedString = NSMutableAttributedString(string: "")
            
            for item in errorOutput.components(separatedBy: .newlines) {
                var newItem = item
                if let range: Range<String.Index> = newItem.range(of: "mips") {
                    newItem.removeSubrange(newItem.startIndex..<range.lowerBound)
                }
                if let range: NSRange = newItem.range(of: "Warning") {
                    let attributedItem = NSMutableAttributedString(string: newItem)
                    attributedItem.addAttributes([.foregroundColor : NSColor.orange as Any], range: range)
                    attributedString.append(NSAttributedString(string: "\n\n"))
                    attributedString.append(attributedItem)
                    warnning_count += 1
                } else if let range: NSRange = newItem.range(of: "warning") {
                    let attributedItem = NSMutableAttributedString(string: newItem)
                    attributedItem.addAttributes([.foregroundColor : NSColor.orange as Any], range: range)
                    attributedString.append(NSAttributedString(string: "\n\n"))
                    attributedString.append(attributedItem)
                    warnning_count += 1
                } else if let range: NSRange = newItem.range(of: "error") {
                    let attributedItem = NSMutableAttributedString(string: newItem)
                    attributedItem.addAttributes([.foregroundColor : NSColor.red as Any], range: range)
                    attributedString.append(NSAttributedString(string: "\n\n"))
                    attributedString.append(attributedItem)
                    error_count += 1
                }  else if let range: NSRange = newItem.range(of: "Error") {
                    let attributedItem = NSMutableAttributedString(string: newItem)
                    attributedItem.addAttributes([.foregroundColor : NSColor.red as Any], range: range)
                    attributedString.append(NSAttributedString(string: "\n\n"))
                    attributedString.append(attributedItem)
                    error_count += 1
                } else {
                    attributedString.append(NSAttributedString(string: "\n"))
                    attributedString.append(NSAttributedString(string: newItem))
                }
            }
            // show the error message in side panel
            compilerMessageViewController?.textView.textStorage?.setAttributedString(attributedString)
            compilerMessageViewController?.view.window?.makeKeyAndOrderFront(self)
            
            self.viewController.sidePanelInfoTextView.textStorage?.setAttributedString(attributedString)
            
            // post a notification to inform the user
            let message: String
            if error_count > 0 {
                message = NSLocalizedString("Failed", comment: "Failed") + ": \(warnning_count) warnnings and \(error_count) errors!"
                InfoAndAlert.shared.postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), informativeText: message)
                return false
            } else {
                message = NSLocalizedString("Some warnning!", comment: "Some warnnings!") + ": \(warnning_count) warnnings!"
                InfoAndAlert.shared.postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), informativeText: message)
                return true
            }
        } else {
            self.viewController.sidePanelInfoTextView.string = ""
            compilerMessageViewController?.textView.string = ""
            // post a notification to inform the user
            InfoAndAlert.shared.postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), informativeText: NSLocalizedString("Succeeded", comment: "Succeeded"))
            return true
        }
    }
    //*********************** About build binary **************************
    var buildSuccess = false
    @IBAction func buildBinary(_ sender: Any) {
        // Save the modification at first
        NSDocumentController.shared.currentDocument?.save(self)
        // get the project
        if let project = self.viewController.project {
            // Update project
            project.updateFileWrappers()
            project.updateSourceFiles()
            // Create a compiler
            let aCompiler = Compiler(forProject: project)
            
            /// internal function in buildLibrary
            func buildBinaryAndCheckResult() {
                // Build the binary
                let (_, errorOutput) = aCompiler.buildBinary()
                self.buildSuccess = self.updateBuildResult(errorOutput: errorOutput)
                // update project again
                project.updateFileWrappers()
            }
            
            // use customed makefile instead
            if project.useCustomedMakefile {
                // make sure the makefile does exist
                if (project.filewrappers?.fileWrappers?.keys.contains("Makefile"))! {
                    buildBinaryAndCheckResult()
                } else {
                    // makefile doesn't exist
                    self.viewController.sidePanelInfoTextView.string = "Customed Makefile doesn't exist!"
                    self.viewController.sidePanelTabControl.selectSegment(withTag: 1)
                    self.viewController.sidePanelTabView.selectTabViewItem(at: 1)
                    // post a notification to inform the user
                    InfoAndAlert.shared.postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), informativeText: NSLocalizedString("Failed: Customed Makefile doesn't exist!", comment: "Failed"))
                    self.buildSuccess = false
                }
            } else {
                // generate a makefile before building
                // Generate makefile, if fails, exit
                if aCompiler.generateMakefile() {
                    // Build the binary
                    buildBinaryAndCheckResult()
                } else {
                    // failed to generate the makefile
                    self.viewController.sidePanelInfoTextView.string = "Failed to generate the makefile!"
                    self.viewController.sidePanelTabControl.selectSegment(withTag: 1)
                    self.viewController.sidePanelTabView.selectTabViewItem(at: 1)
                    // post a notification to inform the user
                    InfoAndAlert.shared.postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), informativeText: NSLocalizedString("Failed: Failed to generate the makefile!", comment: "Failed"))
                    self.buildSuccess = false
                }
            }
            // update project inspector
            self.viewController.updateProjectInspector()
        }
    }
    // ******************** About build library **********************
    @IBAction func buildLibrary(_ sender: Any) {
        // Save the modification at first
        NSDocumentController.shared.currentDocument?.save(self)
        // get the project
        if let project = self.viewController.project {
            // Update project
            project.updateFileWrappers()
            project.updateSourceFiles()
            // Create a compiler
            let aCompiler = Compiler(forProject: project)
            
            /// internal function in buildLibrary
            func buildLibraryAndCheckResult() {
                // Build the library
                let (_, errorOutput) = aCompiler.buildLibrary()
                self.buildSuccess = self.updateBuildResult(errorOutput: errorOutput)
                // update project again
                project.updateFileWrappers()
            }
            
            // use customed makefile instead
            if project.useCustomedMakefile {
                // make sure the makefile does exist
                if (project.filewrappers?.fileWrappers?.keys.contains("Makefile"))! {
                    buildLibraryAndCheckResult()
                } else {
                    // makefile doesn't exist
                    self.viewController.sidePanelInfoTextView.string = "Customed Makefile doesn't exist!"
                    self.viewController.sidePanelTabControl.selectSegment(withTag: 1)
                    self.viewController.sidePanelTabView.selectTabViewItem(at: 1)
                    // post a notification to inform the user
                    InfoAndAlert.shared.postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), informativeText: NSLocalizedString("Failed", comment: "Failed"))
                }
            } else {
                // generate a makefile before building
                // Generate makefile, if fails, exit
                if aCompiler.generateMakefile() {
                    // Build the library
                    buildLibraryAndCheckResult()
                } else {
                    // failed to generate the makefile
                    self.viewController.sidePanelInfoTextView.string = "Failed to generate the makefile!"
                    self.viewController.sidePanelTabControl.selectSegment(withTag: 1)
                    self.viewController.sidePanelTabView.selectTabViewItem(at: 1)
                    // post a notification to inform the user
                    InfoAndAlert.shared.postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), informativeText: NSLocalizedString("Failed", comment: "Failed"))
                }
            }
            // update project inspector
            self.viewController.updateProjectInspector()
        }
    }
    // **************** About Clean Project *****************
    @IBAction func cleanProject(_ sender: Any) {
        if let project = self.viewController.project {
            let aCompiler = Compiler(forProject: project)
            _ = aCompiler.generateMakefile()
            _ = aCompiler.cleanProject()
            InfoAndAlert.shared.postNotification(title: NSLocalizedString("Clean Result", comment: "Clean Result"), informativeText: NSLocalizedString("Completed", comment: "Completed"))
            // update project again
            project.updateSourceFiles()
            // update project inspector
            self.viewController.updateProjectInspector()
        }
    }
    //*********************** About upload binary ********************
    @objc var uploader = Uploader()
    var uploadConfigViewController: UploadConfigViewController = {
        let storyBoard = NSStoryboard.init(name: NSStoryboard.Name("UploadConfig"), bundle: nil)
        let uploadConfigViewController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("Upload Config View Controller")) as! UploadConfigViewController
        return uploadConfigViewController
    }()
    @IBAction func loadToBoard(_ sender: Any) {
        if self.uploader.uploadFlag {
            self.uploader.uploadFlag = false
            self.progressInfo.stringValue = NSLocalizedString("Upload Cancelled", comment: "Upload Cancelled")
            // cancel upload
            self.uploader.cancelUpload()
            // setup ui
            self.setupUIBeforeUpload()
            // remove observers
            // self.removeObserversForUpload()
        } else {
            var buildBinary = false
            if let autoBuild = UserDefaults.standard.value(forKey: "AutoBuild") as? NSControl.StateValue {
                if autoBuild == .on {
                    buildBinary = true
                }
            } else {
                buildBinary = true
                UserDefaults.standard.set(NSControl.StateValue.on as Any, forKey: "AutoBuild")
            }
            if buildBinary {
                self.buildBinary(self)
                if !self.buildSuccess {
                    InfoAndAlert.shared.postNotification(title: "Upload Failed", informativeText: "Fail to build a new binary.")
                    return
                }
            }
            if let project = self.viewController.project {
                self.uploader.uploadFlag = true
                // setup ui
                self.setupUIDuringUpload()
                // add observers
                // self.addObserversForUpload()
                // start to upload
                self.uploader.targetAddress = project.targetAddress
                self.uploader.binaryURL = project.projectURL?.appendingPathComponent("Release").appendingPathComponent("\(project.targetName).bin")
                // show the upload config sheet
                if !self.uploader.uploadConfigReady {
                    self.uploadConfigViewController.parentVC = self.contentViewController as! DocumentViewController
                    self.viewController.presentViewControllerAsSheet(self.uploadConfigViewController)
                } else {
                    self.uploader.startUpload()
                    self.uploader.uploadStageControl(nil)
                }
            }
        }
    }
    /// Add Observers for upload: Used in windowsDidLoad
    func addObserversForUpload() {
        // uploading cancelled, from upload config view controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadToBoard(_:)), name: NSNotification.Name.uploadingCancelled, object: self.viewController)
        // updated progress, from uploader
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)), name: NSNotification.Name.updatedProgress, object: self.uploader)
        // uploading failed, from uploader
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadFailed(_:)), name: NSNotification.Name.uploadingFailed, object: self.uploader)
        // uploading succeeded, from uploader
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadSucceeded(_:)), name: NSNotification.Name.uploadingSucceeded, object: self.uploader)
    }
    /// Remove Observers for upload: Not used now!
    func removeObserversForUpload() {
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.timeForNextUploadStage, object: self.uploadConfigViewController)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.uploadingCancelled, object: self.viewController)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.uploadingFailed, object: self.uploader)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.uploadingSucceeded, object: self.uploader)
        
    }
    /// The official signal of uploading is from uploadingConfigViewController
    @objc func nextUploadStage(_ aNotification: Notification) {
        self.uploader.uploadStageControl(aNotification)
    }
    /// Update progress information from uploader to progressInfo and progressValue
    @objc func updateProgress(_ aNotification: Notification?) {
        self.progressInfo.stringValue = self.uploader.progressInfo
        self.progressIndicator.doubleValue = self.uploader.progressValue
    }
    
    @objc func uploadSucceeded(_ aNotification: Notification) {
        self.updateProgress(nil)
        let alert = NSAlert()
        // add OK button
        alert.addButton(withTitle: "OK")
        // set the alert title
        alert.messageText = NSLocalizedString("Upload Result", comment: "Upload Result")
        alert.icon = #imageLiteral(resourceName: "ic_done")
        alert.informativeText = self.uploader.uploadResult
        alert.alertStyle = .informational
        alert.beginSheetModal(for: self.window!, completionHandler: nil)
        self.setupUIBeforeUpload()
        self.uploader.cancelUpload()
    }
    
    @objc func uploadFailed(_ aNotification: Notification) {
        // Empty all notification
        NSUserNotificationCenter.default.scheduledNotifications.removeAll()
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        self.progressInfo.stringValue = NSLocalizedString("Upload Failed", comment: "Upload Failed")
        self.progressInfo.needsDisplay = true
        // cancel upload
        self.uploader.cancelUpload()
        // setup ui
        self.setupUIBeforeUpload()
    }
    
    func setupUIBeforeUpload() {
        self.loadToBoardButton.image = #imageLiteral(resourceName: "ic_get_app")
        self.loadToBoardButton.needsDisplay = true
        self.loadToBoardButtonInTouchbar.image = #imageLiteral(resourceName: "ic_file_download_white")
        self.loadToBoardButtonInTouchbar.needsDisplay = true
        self.progressIndicator.doubleValue = 0.0
        self.progressIndicator.stopAnimation(self)
        self.progressIndicator.isHidden = true
        self.progressIndicator.needsDisplay = true
    }
    
    func setupUIDuringUpload() {
        /*
        self.serialMonitorButton.isEnabled = false
        self.serialMonitorButton.needsDisplay = true
        self.serialMonitorButtonInTouchbar.isEnabled = false
        self.serialMonitorButtonInTouchbar.needsDisplay = true
        */
        self.loadToBoardButton.image = #imageLiteral(resourceName: "ic_highlight_off")
        self.loadToBoardButton.needsDisplay = true
        self.loadToBoardButtonInTouchbar.image = #imageLiteral(resourceName: "ic_highlight_off_white")
        self.loadToBoardButtonInTouchbar.needsDisplay = true
        self.progressIndicator.isHidden = false
        self.progressIndicator.doubleValue = 0.0
        self.progressIndicator.startAnimation(self)
        self.progressIndicator.needsDisplay = true
    }
    
    func addWindowAsTab() {
        NSApp.mainWindow?.addTabbedWindow(self.window!, ordered: .above)
    }
}

extension DocumentWindowController: NSUserNotificationCenterDelegate {
    /// NSUserNotifcationCenterDelegate function
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            center.removeDeliveredNotification(notification)
        }
    }
    /// NSUserNotifcationCenterDelegate function
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
