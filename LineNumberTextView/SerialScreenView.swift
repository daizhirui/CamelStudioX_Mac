//
//  SerialScreenView.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/4.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

extension NSNotification.Name {
    static public let userInput = NSNotification.Name("userInput")
}

public class SerialScreenView: NSTextView {
    
    public var userInput: String = ""
    var userInputCount = 0
    //var serialController: SerialController!
    
    func processUserInput() {
        //self.textStorage?.mutableString.append(self.userInput)
        //var range = NSMakeRange((self.textStorage?.mutableString.length)! - 1, 1)
        //self.textStorage?.setAttributes([NSAttributedStringKey.foregroundColor : NSColor.systemBlue], range:range)
        //[NSAttributedStringKey.foregroundColor : NSColor.systemBlue]
        
        let attributedInput = NSAttributedString(string: self.userInput, attributes: [ NSAttributedStringKey.font : NSFont(name:"Helvetica Bold", size: 13)! ])
        self.textStorage?.append(attributedInput)
    }
    
    override public func keyDown(with event: NSEvent) {
        if let chars = event.characters {
            // User does input something
            self.userInput = chars
            if event.keyCode == 51 {
                print("keyCode = \(event.keyCode)")
                if self.userInputCount > 0 {
                    let range = NSMakeRange((self.textStorage?.mutableString.length)! - 1, 1)
                    self.textStorage?.mutableString.deleteCharacters(in: range)
                    self.userInputCount -= 1
                }
            } else {
                self.userInputCount += 1
                self.processUserInput()
            }
            NotificationCenter.default.post(name: NSNotification.Name.userInput, object: self)
        }
        /*  // for debug
        for code in userInput.utf8 {
            print(code, terminator: " ")
        }*/
    }
    
    //*********** The following part is from LineNumberTextView
    /// Holds the attached line number gutter.
    private var lineNumberGutter: LineNumberGutter?
    
    /// Holds the text color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var lineNumberForegroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
                let color  = self.lineNumberForegroundColor {
                gutter.foregroundColor = color
            }
        }
    }
    
    /// Holds the background color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var lineNumberBackgroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
                let color  = self.lineNumberBackgroundColor {
                gutter.backgroundColor = color
            }
        }
    }
    
    
    override public func awakeFromNib() {
        // Get the enclosing scroll view
        guard let scrollView = self.enclosingScrollView else {
            fatalError("Unwrapping the text views scroll view failed!")
        }
        
        if let gutterBG = self.lineNumberBackgroundColor,
            let gutterFG = self.lineNumberForegroundColor {
            self.lineNumberGutter = LineNumberGutter(withTextView: self, foregroundColor: gutterFG, backgroundColor: gutterBG)
        } else {
            self.lineNumberGutter = LineNumberGutter(withTextView: self)
        }
        
        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true
        
        self.addObservers()
    }
    // used when created not from storyboard
    public func openLineNumber() {
        // Get the enclosing scroll view
        guard let scrollView = self.enclosingScrollView else {
            fatalError("Unwrapping the text views scroll view failed!")
        }
        
        if let gutterBG = self.lineNumberBackgroundColor,
            let gutterFG = self.lineNumberForegroundColor {
            self.lineNumberGutter = LineNumberGutter(withTextView: self, foregroundColor: gutterFG, backgroundColor: gutterBG)
        } else {
            self.lineNumberGutter = LineNumberGutter(withTextView: self)
        }
        
        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true
        
        self.addObservers()
    }
    /// Add observers to redraw the line number gutter, when necessary.
    internal func addObservers() {
        self.postsFrameChangedNotifications = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(LineNumberTextView.drawGutter), name: NSView.frameDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(LineNumberTextView.drawGutter), name: NSText.didChangeNotification, object: self)
    }
    
    /// Set needsDisplay of lineNumberGutter to true.
    @objc internal func drawGutter() {
        if let lineNumberGutter = self.lineNumberGutter {
            lineNumberGutter.needsDisplay = true
        }
    }
}
