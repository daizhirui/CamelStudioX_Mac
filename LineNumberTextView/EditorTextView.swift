//
//  EditorTextView.swift
//  LineNumberTextView
//
//  Created by 戴植锐 on 2018/5/21.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

struct StringInsertion {
    var position: Int = 0
    var character: Character = "\0"
}

public extension NSNotification.Name {
    static let TextDidChangeNotification = NSNotification.Name("TextDidChangeNotification")
}

struct CharacterRegx {
    let leftCurlyBrace = try! NSRegularExpression(pattern: "\\{", options: [])
    let rightCurlyBrace = try! NSRegularExpression(pattern: "\\}", options: [])
    let leftParenthesis = try! NSRegularExpression(pattern: "\\(", options: [])
    let rightParenthesis = try! NSRegularExpression(pattern: "\\)", options: [])
}

public class EditorTextView: NSTextView {

    var tabCount = 0
    var punctuationCount = 0
    
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    func simulatedKeyDown(keyCode: CGKeyCode, useCommandFlag: Bool) {
        let sourceRef = CGEventSource(stateID: .combinedSessionState)
        if sourceRef == nil {
            NSLog("FakeKey: No event source")
            return
        }
        let keyDownEvent = CGEvent(keyboardEventSource: sourceRef,
                                   virtualKey: keyCode,
                                   keyDown: true)
        if useCommandFlag {
            keyDownEvent?.flags = .maskCommand
        }
        let keyUpEvent = CGEvent(keyboardEventSource: sourceRef,
                                 virtualKey: keyCode,
                                 keyDown: false)
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    
    func insertCharacter(with insertion: StringInsertion) {
        self.undoManager?.registerUndo(withTarget: self) {
            target in
            target.removeCharacter(with: insertion)
        }
        let position = self.string.index(self.string.startIndex, offsetBy: insertion.position)
        self.string.insert(insertion.character, at: position)
        self.setSelectedRange(NSMakeRange(insertion.position, 0))
    }
    
    func removeCharacter(with insertion: StringInsertion) {
        self.undoManager?.registerUndo(withTarget: self) {
            target in
            target.insertCharacter(with: insertion)
        }
        let position = self.string.index(self.string.startIndex, offsetBy: insertion.position)
        self.string.remove(at: position)
        self.setSelectedRange(NSMakeRange(insertion.position, 0))
    }
    
    /******** Auto Indent! *********/
    static let characterRegx = CharacterRegx()
    override public func keyDown(with event: NSEvent) {
        
        if event.keyCode == 48 {
            let cursorPos = self.selectedRange().lowerBound
            let sequenceToInsert = String(repeating: " ", count: 4)
            self.string.insert(contentsOf: sequenceToInsert, at: self.string.index(self.string.startIndex, offsetBy: cursorPos))
            self.setSelectedRange(NSMakeRange(cursorPos + 4, 0))
            return
        }
        
        super.keyDown(with: event)
        
        let cursorPos = self.selectedRange().lowerBound
        if event.keyCode == 36 {
            let leftCurlyBraceCount = EditorTextView.characterRegx.leftCurlyBrace.matches(in: self.string,
                                                                                          options: [],
                                                                                          range: NSMakeRange(0, cursorPos - 1)).count
            let rightCurlyBraceCount = EditorTextView.characterRegx.rightCurlyBrace.matches(in: self.string,
                                                                                            options: [],
                                                                                            range: NSMakeRange(0, cursorPos - 1)).count
            let numberOfSpacesToInsertBefore = (leftCurlyBraceCount - rightCurlyBraceCount) * 4;
            
            var sequenceToInsert = String(repeating: " ", count: numberOfSpacesToInsertBefore)
            
            if cursorPos < self.string.count {
                let nextCharacter = (self.string as NSString).substring(with: NSMakeRange(cursorPos, 1))
                
                if nextCharacter == "}" {
                    let numberOfSpacesToInsertAfter = numberOfSpacesToInsertBefore - 4
                    sequenceToInsert.append("\n")
                    sequenceToInsert.append(String(repeating: " ", count: numberOfSpacesToInsertAfter))
                }
            }
            self.insertText(sequenceToInsert, replacementRange: NSMakeRange(cursorPos, 0))
            self.setSelectedRange(NSMakeRange(cursorPos + numberOfSpacesToInsertBefore, 0))
        }
        else if event.characters == "{" {
            self.insertText("}", replacementRange: NSMakeRange(cursorPos, 0))
            self.setSelectedRange(NSMakeRange(cursorPos, 0))
        }
        else if event.characters == "(" {                 /*! Smart "(" insertion */
            self.insertText(")", replacementRange: NSMakeRange(cursorPos, 0))
            self.setSelectedRange(NSMakeRange(cursorPos, 0))
        }
        else if event.characters == ")" {                 /*! Smart ")" insertion */
            if cursorPos < self.string.count {
                let nextCharacter = (self.string as NSString).substring(with: NSMakeRange(cursorPos, 1))
                if nextCharacter == ")" {
                    let leftParenthesisCount = EditorTextView.characterRegx.leftParenthesis.matches(in: self.string,
                                                                                                    options: [],
                                                                                                    range: NSMakeRange(0, cursorPos - 1)).count
                    let rightParenthesisCount = EditorTextView.characterRegx.rightParenthesis.matches(in: self.string,
                                                                                                      options: [],
                                                                                                      range: NSMakeRange(0, cursorPos - 1)).count
                    if leftParenthesisCount - rightParenthesisCount > 0 {
                        self.removeCharacter(with: StringInsertion(position: cursorPos, character: ")"))
                        self.setSelectedRange(NSMakeRange(cursorPos, 0))
                    }
                }
            }
        }
        else if event.characters == "\"" || event.characters == "'" {
            self.string.insert(contentsOf: event.characters!, at: self.string.index(self.string.startIndex, offsetBy: cursorPos))
            self.setSelectedRange(NSMakeRange(cursorPos, 0))
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.TextDidChangeNotification, object: self)
    }
    
    public func setLinumberGutterColor(foreground: NSColor, background: NSColor) {
        self.lineNumberBackgroundColor = background
        self.lineNumberForegroundColor = foreground
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
