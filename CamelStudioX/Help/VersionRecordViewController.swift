//
//  WhatIsNewViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/3/24.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import WebKit
import Markdown

class WhatIsNewViewController: NSViewController {

    @IBOutlet var whatisnewTextView: WebView!
    /*
    let template =
        """
        <!doctype html>
        <html>
        <head>
            <style>
                body { margin: 0; padding: 10px; font: normal 1em/1.4 "Helvetica Neue", helvetica, sans-serif; }
                h1, h2, h3, h4, h5, h6 { font-weight: 400; margin: .2em 0; }
                h1 { font-size: 2.00em; }
                h2 { font-size: 1.60em; }
                h3 { font-size: 1.40em; }
                h4 { font-size: 1.30em; }
                h5 { font-size: 1.20em; }
                h6 { font-size: 1.10em; }
                code { font-size: 1.1em; }
                pre { font-size: 1.2em; padding: 10px; background-color: #FAFAFA; border: 1px solid #EEE; border-radius: 3px; }
                blockquote { margin: .2em 0; padding-left: 1em; border-left: 2px solid #CCC; color: #666; }
            </style>
        </head>
        <body>
            {{TEXT}}
        </body>
        </html>
        """*/
    override func viewDidLoad() {
        super.viewDidLoad()
        if let content = try? String(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/Contents/Resources/README.md"), encoding: String.Encoding.utf8) {
            if let md = try? Markdown(string: content) {
                if let document = try? md.document() {
                    //let html = template.replacingOccurrences(of: "{{TEXT}}", with: document)
                    self.whatisnewTextView.mainFrame.loadHTMLString(document, baseURL: nil)
                    self.whatisnewTextView.needsDisplay = true
                }
            }
        }
    }
}
