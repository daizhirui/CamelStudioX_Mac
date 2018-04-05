//
//  WelcomeWindowController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/4.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
/*
@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    static let welcomeTouchBar = NSTouchBar.CustomizationIdentifier("com.camel.welcomeTouchBar")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static let newProjectButton = NSTouchBarItem.Identifier("com.camel.TouchBarItem.newProjectButton")
    static let openProjectButton = NSTouchBarItem.Identifier("com.camel.TouchBarItem.openProjectButton")
}*/

@available(OSX 10.12.2, *)
class WelcomeWindowController: NSWindowController {
    
    @IBOutlet weak var welcomeTouchBar: NSTouchBar!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        NSApp.touchBar = welcomeTouchBar
    }
    /*
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .welcomeTouchBar
        touchBar.defaultItemIdentifiers = [.flexibleSpace, .newProjectButton, .fixedSpaceLarge, .openProjectButton, .flexibleSpace]
        touchBar.customizationAllowedItemIdentifiers = []
        return touchBar
    }*/
}
/*
extension WelcomeWindowController: NSTouchBarDelegate {
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let custom = NSCustomTouchBarItem(identifier: identifier)
        switch identifier {
        case .newProjectButton :
            custom.customizationLabel = "New Project"
            let button = NSButton(title: "New Project", target: self, action: #selector((self.contentViewController as! WelcomeViewController).createNewProject(_:)))
            custom.view = button
            return custom
        case .openProjectButton:
            custom.customizationLabel = "Open Project"
            let button = NSButton(title: "Open Project", target: self, action: #selector((self.contentViewController as! WelcomeViewController).openProject(_:)))
            custom.view = button
            return custom
        default:
            return custom
        }
    }
}*/

