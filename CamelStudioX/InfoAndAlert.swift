//
//  ShowAlertWindow.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/3/20.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

func showAlertWindow(with message: String) -> NSAlert {
    let alert = NSAlert()
    // add OK button
    alert.addButton(withTitle: "OK")
    // set the alert title
    alert.messageText = NSLocalizedString("Alert", comment: "NSAlert Title")
    alert.informativeText = message
    alert.alertStyle = .critical
    alert.runModal()
    return alert
}

func postNotification(title: String, message: String) {
    // prepare the notification
    let userNotificationCenter = NSUserNotificationCenter.default
    let userNote = NSUserNotification()
    userNote.title = title
    userNote.soundName = NSUserNotificationDefaultSoundName
    userNote.informativeText = message
    // post the notification
    userNotificationCenter.deliver(userNote)
}
