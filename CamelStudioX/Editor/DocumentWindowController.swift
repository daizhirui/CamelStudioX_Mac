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
        NSUserNotificationCenter.default.delegate = self
        // addObservers
        NotificationCenter.default.addObserver(self, selector: #selector(self.lostFocusAction(_:)), name: NSWindow.didResignMainNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getFocusAction(_:)), name: NSWindow.didBecomeMainNotification, object: nil)
        // check if a tab window is required
        if AppDelegate.isRequiringNewTab {
            self.addWindowAsTab()
            AppDelegate.isRequiringNewTab = false
        }
        self.progressIndicator.isHidden = true
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
    @IBAction func toggelSidePanel(_ sender: Any) {
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
                if let menuItem = sender as? NSMenuItem {
                    menuItem.state = (menuItem.state == .on ? .off : .on)
                } else {
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
    //*********************** About build binary **************************
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
            // Generate makefile, if fails, exit
            if aCompiler.generateMakefile() {
                // Build the binary
                let (_, errorOutput) = aCompiler.buildBinary()
                if errorOutput.count > 0 {
                    // show the error message in side panel
                    self.viewController.sidePanelInfoTextView.string = errorOutput
                    self.viewController.sidePanelTabControl.selectSegment(withTag: 1)
                    self.viewController.sidePanelTabView.selectTabViewItem(at: 1)
                    // post a notification to inform the user
                    postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), message: NSLocalizedString("Failed", comment: "Failed"))
                } else {
                    self.viewController.sidePanelInfoTextView.string = ""
                    // post a notification to inform the user
                    postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), message: NSLocalizedString("Succeeded", comment: "Succeeded"))
                }
                // update project again
                project.updateFileWrappers()
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
            // Generate makefile, if fails, exit
            if aCompiler.generateMakefile() {
                // Build the binary
                let (_, errorOutput) = aCompiler.buildLibrary()
                if errorOutput.count > 0 {
                    // show the error message in side panel
                    self.viewController.sidePanelInfoTextView.string = errorOutput
                    self.viewController.sidePanelTabControl.selectSegment(withTag: 1)
                    self.viewController.sidePanelTabView.selectTabViewItem(at: 1)
                    // post a notification to inform the user
                    postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), message: NSLocalizedString("Failed", comment: "Failed"))
                } else {
                    self.viewController.sidePanelInfoTextView.string = ""
                    // post a notification to inform the user
                    postNotification(title: NSLocalizedString("Build Result", comment: "Build Result"), message: NSLocalizedString("Succeeded", comment: "Succeeded"))
                }
                // update project again
                project.updateFileWrappers()
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
            postNotification(title: NSLocalizedString("Clean Result", comment: "Clean Result"), message: NSLocalizedString("Completed", comment: "Completed"))
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
            self.progressInfo.stringValue = NSLocalizedString("Upload Cancelled", comment: "Upload Cancelled")
            // cancel upload
            self.uploader.cancelUpload()
            // setup ui
            self.setupUIBeforeUpload()
            // remove observers
            self.removeObserversForUpload()
        } else {
            if let project = self.viewController.project {
                // setup ui
                self.setupUIDuringUpload()
                // add observers
                self.addObserversForUpload()
                // start to upload
                self.uploader.targetAddress = project.targetAddress
                self.uploader.binaryURL = project.projectURL?.appendingPathComponent("Release").appendingPathComponent("\(project.targetName).bin")
                self.uploader.startUpload()
                // show the upload config sheet
                self.uploadConfigViewController.parentVC = self.contentViewController as! DocumentViewController
                self.viewController.presentViewControllerAsSheet(self.uploadConfigViewController)
            }
        }
    }
    /// Add Observers for upload
    func addObserversForUpload() {
        // time for next stage, from upload config view controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextUploadStage(_:)), name: NSNotification.Name.timeForNextUploadStage, object: self.uploadConfigViewController)
        // uploading cancelled, from upload config view controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadToBoard(_:)), name: NSNotification.Name.uploadingCancelled, object: self.uploadConfigViewController)
        // updated progress, from uploader
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgress(_:)), name: NSNotification.Name.updatedProgress, object: self.uploader)
        // uploading failed, from uploader
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadFailed(_:)), name: NSNotification.Name.uploadingFailed, object: self.uploader)
        // uploading succeeded, from uploader
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadSucceeded(_:)), name: NSNotification.Name.uploadingSucceeded, object: self.uploader)
    }
    /// Remove Observers for upload
    func removeObserversForUpload() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.timeForNextUploadStage, object: self.uploadConfigViewController)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.uploadingCancelled, object: self.uploadConfigViewController)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.uploadingFailed, object: self.uploader)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.uploadingSucceeded, object: self.uploader)
        
    }
    /// The official signal of uploading is from uploadingConfigViewController
    @objc func nextUploadStage(_ aNotification: Notification) {
        self.uploader.forwardToNextStage()
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
        /*
        self.serialMonitorButton.isEnabled = true
        self.serialMonitorButton.needsDisplay = true
        self.serialMonitorButtonInTouchbar.isEnabled = true
        self.serialMonitorButtonInTouchbar.needsDisplay = true
         */
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
