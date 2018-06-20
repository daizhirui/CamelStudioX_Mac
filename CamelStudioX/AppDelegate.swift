//
//  AppDelegate.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/1.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import Sparkle
import HockeySDK

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SUUpdaterDelegate {
    
    static var shared: AppDelegate!
    @IBOutlet weak var updater: SUUpdater!
    let hockeyManager = BITHockeyManager.shared()
    
    override init() {
        super.init()
        if AppDelegate.shared == nil {
            AppDelegate.shared = self
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Menu bar
        self.setupM2ExampleMenu()
        // Touch bar
        if #available(OSX 10.12.2, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
        // Modal window
        NotificationCenter.default.addObserver(self,selector: #selector(self.modalWindowClosed(_:)),name: NSWindow.willCloseNotification, object: nil)
        // Welcome window
        self.showWelcomeWindow(self)
        // check driver
        self.checkDriver()
        // Crash, Feedback Reporter
        self.setupHockeySDK()
    }
    
//    - (NSArray *)feedParametersForUpdater:(SUUpdater *)updater
//    sendingSystemProfile:(BOOL)sendingProfile {
//    return [[BITSystemProfile sharedSystemProfile] systemUsageData];
//    }
    
    func feedParameters(for updater: SUUpdater, sendingSystemProfile sendingProfile: Bool) -> [[String : String]] {
        return BITSystemProfile.shared().systemUsageData() as! [[String : String]]
    }
    
    /// Setup Hockey App SDK.
    func setupHockeySDK() {
        hockeyManager?.configure(withIdentifier: "798a2dae49b04400bcadaf69bda80417")
        hockeyManager?.crashManager.isAutoSubmitCrashReport = true
        if let userID = UserDefaults.standard.object(forKey: "UserID") as? String,
            let userName = UserDefaults.standard.object(forKey: "UserName") as? String,
            let userMailAddress = UserDefaults.standard.object(forKey: "UserMailAddress") as? String {
            hockeyManager?.setUserID(userID)
            hockeyManager?.setUserName(userName)
            hockeyManager?.setUserEmail(userMailAddress)
        } else {
            self.openRegisterWindow()
        }
        hockeyManager?.start()
    }
    
    /// Open register window to collect user's name and mail address.
    var reRegister = false
    func openRegisterWindow() {
        let sb = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Register"), bundle: nil)
        if let registerWC = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("RegisterWindowController")) as? NSWindowController {
            NSApp.runModal(for: registerWC.window!)
        }
    }
    
    /// Check if serial driver is installed.
    func checkDriver() {
        let checkDriver: Bool
        if let noCheckDriver = UserDefaults.standard.object(forKey: "Don't Show Alert: SerialDriverDetect") as? Bool {
            checkDriver = !noCheckDriver
        } else {
            checkDriver = true
        }
        if checkDriver {
            if !SerialDriverManager.serialDriverDetected {
                _ = InfoAndAlert.shared.showAlertWindow(with: "No serial driver detected, do you want to install a serial driver?", allowCancel: true, showDontShowAgain: true, completedHandler: {
                    SerialDriverManager.chooseInstaller()
                })
            }
        }
    }
    
    /// This function is invocked when a modal window is being closed.
    @objc func modalWindowClosed(_ aNotification: Notification){
        if let window = aNotification.object as? NSWindow {
            // To close Modal Window
            if let modalWindow = InfoAndAlert.currentAlert, modalWindow == window {
                NSApplication.shared.stopModal()
            }
        }
    }
    
    /// Show the welcome window if necessary.
    @objc func showWelcomeWindow(_ sender: Any?) {
        if WelcomeViewController.shouldShow { // check if the welcome window should be showed
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Welcome"), bundle: nil)
            let windowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("Welcome Window Controller")) as! NSWindowController
            windowController.showWindow(self)
        } else {
            myDebug("NSApp.windows.count = \(NSApp.windows.count)")
            myDebug("WelcomeViewController.welcomeViewDidShowed = \(WelcomeViewController.welcomeViewDidShowed)")
        }
    }
    // MARK:- Restoration and WelcomeWindow
    static var isRestoring = false
    
    /// Start to restore
    func application(_ app: NSApplication, didDecodeRestorableState coder: NSCoder) {
        myDebug("Application is restoring.")
        AppDelegate.isRestoring = true
    }
    /// Restoration may be successful, check it
    func applicationDidBecomeActive(_ notification: Notification) {
        myDebug("Application become active")
        AppDelegate.isRestoring = false
        if !WelcomeViewController.welcomeViewDidShowed && DocumentViewController.openedDocumentViewController <= 0 {
            // fail to restore, show welcome window
            self.showWelcomeWindow(self)
        }
    }
    /// Reopen welcome Window when there is no window
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        self.showWelcomeWindow(self)
        return true
    }
    
    // MARK:- Termination
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        NSApplication.shared.modalWindow?.close()
        NSApplication.shared.abortModal()
        InfoAndAlert.currentAlert?.close()
    }
    
    
    
    // MARK:- UntiledFile Process
    /// The process of creating a new project should be controlled by the welcome window
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // MARK:- Tab window
    static var isRequiringNewTab = false
    /// NewTab MenuItem is binded to this, so its enableness state can be controlled.
    @objc var shouldEnableNewTabMenu: Bool {
        get {
            return !WelcomeViewController.welcomeViewDidShowed
        }
    }
    /// create a new document and add its window as a tab
    @IBAction func addTabbedWindow(_ sender: Any) {
        AppDelegate.isRequiringNewTab = true
        NSDocumentController.shared.newDocument(self)
    }
    // MARK:- M2 Example Menu
    /// Store paths of every example file so that these examples can be opened later.
    var m2ExampleList: [String : URL] = [String : URL]()
    /// UI element of M2 Example
    @IBOutlet weak var m2ExampleMenu: NSMenu!
    /// Setup the M2 Example menu for examples
    func setupM2ExampleMenu() {
        // For M2
        if let exampleFileList = try? FileManager.default.contentsOfDirectory(atPath: "\(Bundle.main.bundlePath)/Contents/Resources/Developer/Examples/M2") {
            for exampleFile in exampleFileList {
                var isDirectory: ObjCBool = false  // make sure it is a Directory
                FileManager.default.fileExists(atPath: "\(Bundle.main.bundlePath)/Contents/Resources/Developer/Examples/M2/\(exampleFile)", isDirectory: &isDirectory)
                if isDirectory.boolValue {   // OK, it is a directory
                    if exampleFile.hasSuffix(".cmsproj") {
                        var title = exampleFile
                        title.removeLast(".cmsproj".count)
                        let exampleMenuItem = NSMenuItem()
                        exampleMenuItem.title = "\(title)"
                        exampleMenuItem.target = self
                        exampleMenuItem.action = #selector(self.m2ExamplesMenu(_:))
                        self.m2ExampleList[title] = URL(fileURLWithPath: "\(Bundle.main.bundlePath)/Contents/Resources/Developer/Examples/M2/\(exampleFile)")
                        self.m2ExampleMenu.addItem(exampleMenuItem)
                    }
                }
            }
        }
    }
    // MARK:- Responders
    /// Responder to opening an example.
    @objc func m2ExamplesMenu(_ sender: Any) {
        let menu = sender as! NSMenuItem
        NSDocumentController.shared.openDocument(withContentsOf: self.m2ExampleList[menu.title]!, display: true, completionHandler: { document, result, error in
            if error != nil {
                myDebug("\(error!)")
            }
        })
    }
    /// Responder to showing Preference Window
    @IBAction func openPreference(_ sender: Any) {
        let sb = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Preference"), bundle: nil)
        if let preferenceWindowController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PreferenceWindowController")) as? NSWindowController {
            if let preferenceViewController = preferenceWindowController.contentViewController as? PreferenceViewController {
                if let mainVC = NSApp.mainWindow?.windowController?.contentViewController as? DocumentViewController {
                    preferenceViewController.mainVC = mainVC
                }
                preferenceWindowController.showWindow(self)
            }
        }
    }
    /// Responder to showing driver installation window
    @IBAction func openDriverInstaller(_ sender: Any) {
        //let test: String? = nil
        //print(test!)
        SerialDriverManager.chooseInstaller()
    }
    /// Responder to showing the documentation
    @IBAction func showDocumentation(_ sender: Any) {
        let url = Bundle.main.bundleURL.appendingPathComponent("/Contents/Resources/Developer/OfficialLibrary/doc/index.html")
        NSWorkspace.shared.open(url)
    }
    @IBAction func onFeedback(_ sender: Any) {
        self.hockeyManager?.feedbackManager.showAlertOnIncomingMessages = true
        self.hockeyManager?.feedbackManager.requireUserEmail = .required
        self.hockeyManager?.feedbackManager.requireUserName = .required
        self.hockeyManager?.feedbackManager.showFeedbackWindow()
    }
    @IBAction func onReregister(_ sender: Any) {
        self.reRegister = true
        self.openRegisterWindow()
    }
}

