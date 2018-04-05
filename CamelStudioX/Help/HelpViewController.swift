//
//  HelpViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/3/25.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import LineNumberTextView
import Highlightr

class HelpViewController: NSViewController {
    
    var helpFileWrapper: FileWrapper!

    @IBOutlet weak var treeView: NSOutlineView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var textView: LineNumberTextView!
    var highlightr = Highlightr()!
    var lastSelectedItem: NSTextField?
    var fileOnShow: FileWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.helpFileWrapper = try? FileWrapper(url: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/include/"), options: .immediate)
        // 设置高亮方案
        highlightr.setTheme(to: "arduino-light")
        // 打开行号显示
        self.textView.gutterBackgroundColor = highlightr.theme.themeBackgroundColor
        self.textView.gutterForegroundColor = NSColor.darkGray
        self.textView.openLineNumber()
        // 关闭智能引号功能, 拼写检查，拼写纠正, 语法检查
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isContinuousSpellCheckingEnabled = false
        self.textView.isAutomaticSpellingCorrectionEnabled = false
        self.textView.isGrammarCheckingEnabled = false
        self.treeView.reloadData()
    }
    
    @objc func calculateRegisterButtonPosition(_ aNotification: Notification) {
        let bounds = self.textView.bounds
        let layoutManager = self.textView.textStorage!.layoutManagers[0]
        let textContainer = layoutManager.textContainers[0]
        textContainer.containerSize = NSMakeSize(bounds.size.width, 1.0e7)
        layoutManager.glyphRange(for: textContainer)
        //let naturalSize = layoutManager.usedRect(for: textContainer).size
        let frame = self.scrollView.frame
        self.scrollView.frame = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
    }
    
}

extension HelpViewController: NSOutlineViewDataSource {
    /**
     Return the number of childnodes
     */
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let node: FileWrapper
        if item != nil {
            // unroot node is selected
            node = item as! FileWrapper
        } else {
            // root node is selected
            if let filewrappers = self.helpFileWrapper {
                node = filewrappers
            } else {
                // can't get project.filewrappers
                return 0
            }
        }
        if let childFilewrappers = node.fileWrappers {
            return childFilewrappers.count
        } else {
            // no child filewrappers
            return 0
        }
    }
    
    /**
     Return data container of a selected node and save urlString to the filename property of the container
     */
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let node: FileWrapper
        if item != nil {
            // unroot node is selected
            node = item as! FileWrapper
        } else {
            // root node is selected
            if let filewrappers = self.helpFileWrapper {
                node = filewrappers
            } else {
                // can't get project.filewrappers
                let emptyFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
                return emptyFileWrapper
            }
        }
        if let childFilewrappers = node.fileWrappers {
            let key = childFilewrappers.keys.sorted()[index]
            let fileWrapperForNode = childFilewrappers[key]!
            // store urlString to filename
            if let urlString = node.filename {
                let url = URL(fileURLWithPath: urlString)
                fileWrapperForNode.filename = url.appendingPathComponent(key).relativePath
            }
            return fileWrapperForNode
        } else {
            // no child filewrappers
            return 0
        }
    }
    
    /**
     Return if a node can be expanded
     */
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let fileWrapperForThisNode = item as? FileWrapper {
            // If this is not a directory FileWrapper, exception will occur when we try to get childFileWrappers
            if fileWrapperForThisNode.isDirectory {
                if let childFileWrappers = fileWrapperForThisNode.fileWrappers {
                    return childFileWrappers.count > 0
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

extension HelpViewController: NSOutlineViewDelegate {
    /**
     Return the view of a selected node
     */
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let identifier = tableColumn?.identifier {
            // get the view
            let view = outlineView.makeView(withIdentifier: identifier, owner: self)
            // get the subviews
            let subviews = view?.subviews
            // get imageview
            let imageview = subviews?[0] as! NSImageView
            // get namelabel
            let namelabel = subviews?[1] as! NSTextField
            // get filewrappers, may fail...
            if let model = item as? FileWrapper {
                namelabel.stringValue = model.preferredFilename!
                if model.isDirectory {
                    imageview.image = NSImage(named: NSImage.Name.folder)
                } else {
                    imageview.image = NSImage(named: NSImage.Name("ic_insert_drive_file"))
                }
            }
            return view
        } else {
            return nil
        }
    }
    
    /**
     Return the height of a line
     */
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 20
    }
    /**
     Change the text color when selection is changed
     */
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let projectInspector = notification.object as! NSOutlineView
        let row = projectInspector.selectedRow
        // get the fileWrapper of selected item
        if let model = projectInspector.item(atRow: row) as? FileWrapper {
            if let itemView = projectInspector.rowView(atRow: row, makeIfNecessary: false) {
                let label = (itemView.view(atColumn: 0) as? NSView)?.subviews[1] as? NSTextField
                label?.textColor = NSColor.white
                self.lastSelectedItem?.textColor = NSColor.black
                self.lastSelectedItem = label
            }
            if model.isDirectory {
                // it is a directory
                if let filewrappers = model.fileWrappers {
                    if filewrappers.count > 0 {
                        self.treeView.expandItem(self.treeView.item(atRow: row))
                    }
                }
            } else {
                if let fileData = model.regularFileContents {
                    if let fileString = String(data: fileData, encoding: String.Encoding.utf8) {
                        // show the file
                        self.textView.textStorage?.setAttributedString(self.highlightr.highlight(fileString, as: model.fileLanguage)!)
                        self.fileOnShow = model
                    } else {
                        self.textView.string = NSLocalizedString("Fail to open ", comment: "Fail to open ") + "\(model.preferredFilename!)" + NSLocalizedString("\nUnsupported type!", comment: "\nUnsupported type!")
                    }
                } else {
                    self.textView.string = NSLocalizedString("Fail to open ", comment: "Fail to open ") + "\(model.preferredFilename!)" + NSLocalizedString("\nUnsupported type!", comment: "\nUnsupported type!")
                }
            }
        }
    }
}

