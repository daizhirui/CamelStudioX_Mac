//
//  AppDelegate.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/1.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.setupM2ExampleMenu()
        if #available(OSX 10.12.2, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
        // check if the welcome window should be showed
        if WelcomeViewController.shouldShow {
            // no document is opened or being opened(Restoration), show the welcome window now
            self.showWelcomeWindow(self)
        }
    }
    
    @objc func showWelcomeWindow(_ sender: Any?) {
        if WelcomeViewController.shouldShow {
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Welcome"), bundle: nil)
            let windowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("Welcome Window Controller")) as! NSWindowController
            windowController.showWindow(self)
        } else {
            print("NSApp.windows.count = \(NSApp.windows.count)")
            print("WelcomeViewController.welcomeViewDidShowed = \(WelcomeViewController.welcomeViewDidShowed)")
        }
    }
    //******* About Restoration and WelcomeWindow ********
    static var isRestoring = false
    //static var restorationTimer: Timer?
    /// Start to restore
    func application(_ app: NSApplication, didDecodeRestorableState coder: NSCoder) {
        print("Application is restoring.")
        AppDelegate.isRestoring = true
        //AppDelegate.restorationTimer = Timer(timeInterval: 10, target: self, selector: #selector(self.showWelcomeWindow(_:)), userInfo: nil, repeats: false)
    }
    /// Restoration may be successful, check it
    func applicationDidBecomeActive(_ notification: Notification) {
        print("Application become active")
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
    
    // ************** About Termination ******************
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // The process of creating a new project should be controlled by the welcome window
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
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
    // **************** M2 Example Menu **************
    var m2ExampleList: [String : URL] = [String : URL]()
    @IBOutlet weak var m2ExampleMenu: NSMenu!
    func setupM2ExampleMenu() {
        // For M2
        if let exampleFileList = try? FileManager.default.contentsOfDirectory(atPath: "\(Bundle.main.bundlePath)/Contents/Resources/Developer/Examples/M2") {
            for exampleFile in exampleFileList {
                // make sure it is a Directory
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: "\(Bundle.main.bundlePath)/Contents/Resources/Developer/Examples/M2/\(exampleFile)", isDirectory: &isDirectory)
                if isDirectory.boolValue {
                    // OK, it is a directory
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
    @objc func m2ExamplesMenu(_ sender: Any) {
        let menu = sender as! NSMenuItem
        NSDocumentController.shared.openDocument(withContentsOf: self.m2ExampleList[menu.title]!, display: true, completionHandler: { document, result, error in
            if error != nil {
                print("\(error!)")
            }
        })
    }
    // ****************** About Menu Action *********************
    /// Invoke by preference menu
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
    /// Invoke by install driver menu
    @IBAction func openDriverInstaller(_ sender: Any) {
        let alert = NSAlert()
        // add OK button
        alert.addButton(withTitle: "CH340")
        alert.addButton(withTitle: "PL2303")
        alert.addButton(withTitle: "Cancel")
        // set the alert title
        alert.messageText = NSLocalizedString("Alert", comment: "NSAlert Title")
        alert.informativeText = NSLocalizedString("Please choose the driver", comment: "Please choose the driver")
        alert.alertStyle = .critical
        var window: NSWindow!
        if let mainWindow = NSApp.mainWindow {
            window = mainWindow
        } else {
            self.showWelcomeWindow(self)
            window = WelcomeWindow.windowOnShow
        }
        
        alert.beginSheetModal(for: window, completionHandler: { returnCode in
            print(returnCode)
            if returnCode.rawValue == 1000 {
                if let path = Bundle.main.url(forResource: "ch34x", withExtension: "pkg")?.relativePath {
                    NSWorkspace.shared.openFile(path)
                } else {
                    _ = showAlertWindow(with: NSLocalizedString("ch34x.pkg lost!", comment: "ch34x.pkg lost!"))
                }
            }
            if returnCode.rawValue == 1001 {
                if let path = Bundle.main.url(forResource: "pl2303", withExtension: "pkg")?.relativePath {
                    NSWorkspace.shared.openFile(path)
                } else {
                    _ = showAlertWindow(with: NSLocalizedString("pl2303.pkg lost!", comment: "pl2303.pkg lost!"))
                }
            }
        })
    }
}

