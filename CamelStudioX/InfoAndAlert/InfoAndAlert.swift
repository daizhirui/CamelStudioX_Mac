//
//  InfoAndAlert.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/3/20.
//  Copyright © 2018年 戴植锐. All rights reserved.
//


import Cocoa

class InfoAndAlert: NSObject, NSUserNotificationCenterDelegate {
    
    static let shared: InfoAndAlert = InfoAndAlert()
    static let alertViewController: AlertViewController = {
        let sb = NSStoryboard.init(name: NSStoryboard.Name.init("Alert"), bundle: nil)
        let windowController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("AlertWindowController")) as! NSWindowController
        let viewController = windowController.contentViewController as! AlertViewController
        return viewController
    }()
    static var currentAlert: NSWindow?
    
    override init() {
        super.init()
        NSUserNotificationCenter.default.delegate = self
    }
    
    func showAlertWindow(with message: String) -> NSWindow? {
        InfoAndAlert.alertViewController.informativeText.stringValue = message
        InfoAndAlert.currentAlert = InfoAndAlert.alertViewController.view.window
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            NSApp.runModal(for: InfoAndAlert.alertViewController.view.window!)
        }
        return InfoAndAlert.alertViewController.view.window
    }
    
    // MARK: - Post Notification
    static private let userNotificationCenter = NSUserNotificationCenter.default
    /// Post a notification to the User Notification Center
    func postNotification(title: String, informativeText: String) {
        let userNote = NSUserNotification()
        userNote.title = title
        userNote.informativeText = informativeText
        userNote.soundName = NSUserNotificationDefaultSoundName
        InfoAndAlert.userNotificationCenter.deliver(userNote)
    }
    
    // MARK: - NSUserNotifcationCenterDelegate
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            center.removeDeliveredNotification(notification)
        }
    }
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
