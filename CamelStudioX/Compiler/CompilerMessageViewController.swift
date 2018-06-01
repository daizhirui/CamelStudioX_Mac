//
//  CompilerMessageViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/5/24.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

class CompilerMessageViewController: NSViewController {
    
    static var getCurrent: CompilerMessageViewController {
        get {
            if let vc = CompilerMessageViewController.onShow {
                return vc
            } else {
                return CompilerMessageViewController.loadNew
            }
        }
    }
    
    static var onShow: CompilerMessageViewController?

    static var loadNew: CompilerMessageViewController {
        get {
            let sb = NSStoryboard.init(name: NSStoryboard.Name.init("Alert"), bundle: nil)
            let windowController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("CompilerMessageWindowController")) as! NSWindowController
            return windowController.contentViewController as! CompilerMessageViewController
        }
    }
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        CompilerMessageViewController.onShow = self
    }
    
    override func viewWillDisappear() {
        CompilerMessageViewController.onShow = nil
    }
}
