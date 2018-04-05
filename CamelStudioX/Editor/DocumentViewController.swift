//
//  DocumentViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/1.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import Highlightr
import LineNumberTextView

class DocumentViewController: NSViewController {
    
    static var openedDocumentViewController = 0
    @IBOutlet weak var sidePanelTabView: NSTabView!
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var sidePanelTabControl: NSSegmentedControl!
    @IBOutlet weak var projectInspector: NSOutlineView!
    @IBOutlet var sidePanelInfoTextView: NSTextView!
    @IBOutlet var editArea: LineNumberTextView!
    @IBOutlet weak var languageComboBox: NSComboBox!
    @IBOutlet weak var serialPortStateLabel: NSTextField!
    @IBOutlet var projectInspectorMenu: NSMenu!
    
    // execute with a delay
    var timer: Timer?
    // project manager
    var project: ProjectManager?
    // About Project Inspector
    var lastSelectedItem: NSTextField?
    // About code highligh
    var themeName = "xcode"
    var hignlightr = Highlightr()!
    var fileOnShow: FileWrapper? {
        didSet {
            self.languageComboBox.selectItem(withObjectValue: self.fileOnShow?.fileLanguage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLanguageComboBox()
        self.setupHighlightr()
        // 关闭智能引号功能, 拼写检查，拼写纠正, 语法检查
        self.editArea.isAutomaticQuoteSubstitutionEnabled = false
        self.editArea.isContinuousSpellCheckingEnabled = false
        self.editArea.isAutomaticSpellingCorrectionEnabled = false
        self.editArea.isGrammarCheckingEnabled = false
        self.sidePanelInfoTextView.isAutomaticQuoteSubstitutionEnabled = false
        self.sidePanelInfoTextView.isContinuousSpellCheckingEnabled = false
        self.sidePanelInfoTextView.isAutomaticSpellingCorrectionEnabled = false
        self.sidePanelInfoTextView.isGrammarCheckingEnabled = false
        self.projectInspector.menu = self.projectInspectorMenu
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        DocumentViewController.openedDocumentViewController += 1
        // close welcome window if it hasn't been closed
        if WelcomeViewController.welcomeViewDidShowed {
            WelcomeWindow.windowOnShow.close()
        }
        // check if this is a new project
        self.checkProjectCreation()
        self.updateProjectInspector()
    }
    override func viewWillDisappear() {
        DocumentViewController.openedDocumentViewController -= 1
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    //******************* About project creation *****************
    /**
     Show a sheet to finish the creation of a new project if needed
    */
    func checkProjectCreation() {
        // Check if project hasn't been initialized properly
        // if a document is restored, fileURL isn't ready now
        if !AppDelegate.isRestoring {   // Application is not restoring
            if NSDocumentController.shared.currentDocument?.fileURL == nil {
                let storyBoard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "CreateProject"), bundle: nil)
                if let createProjectViewController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Create Project View Controller")) as? CreateProjectViewController {
                    self.presentViewControllerAsSheet(createProjectViewController)
                } else {
                    self.view.window?.windowController?.close()
                }
            }
        }
    }
    // *************** About side panel **********************
    @IBAction func switchSidePanelTab(_ sender: Any) {
        let tag = self.sidePanelTabControl.selectedSegment
        self.sidePanelTabView.selectTabViewItem(at: tag)
    }
    //***************** About project inspector ******************
    func updateProjectInspector() {
        //self.project?.updateFileWrappers()
        self.projectInspector.reloadData()
    }
    var isOperatingFile = false
    /// Refresh Project inspector
    @IBAction func refreshAction(_ sender: Any) {
        self.project?.updateFileWrappers()
        self.projectInspector.reloadData()
        let index = self.projectInspector.row(forItem: self.fileOnShow)
        self.projectInspector.selectRowIndexes([index], byExtendingSelection: false)
    }
    /// import file, parentNode must be directory type
    @IBAction func importFileToProject(_ sender: Any) {
        // get parent node
        // 获取父节点
        let parentNode: FileWrapper!
        let row = self.projectInspector.selectedRow
        // 没有节点被选中时，默认增加到根节点
        if row < 0 {
            parentNode = self.project?.filewrappers
        }
        else {
            // 节点被选中，获取该节点对应的数据对象
            parentNode = self.projectInspector.item(atRow: row) as? FileWrapper
        }
        // 创建面板
        let openFileDlg = NSOpenPanel()
        openFileDlg.title = NSLocalizedString("Import a file", comment: "Import a file")
        openFileDlg.canChooseFiles = true
        openFileDlg.canChooseDirectories = false
        openFileDlg.allowsMultipleSelection = false
        // 启动面板
        // completionHandler 为面板点击 OK 时执行的操作，此处为打开操作
        openFileDlg.begin(completionHandler: { [weak self] result in
            if (result.rawValue == NSApplication.ModalResponse.OK.rawValue) {
                let fileURLs = openFileDlg.urls
                for url: URL in fileURLs {
                    if let importedFileWrapper = try? FileWrapper(url: url, options: .immediate) {
                        parentNode?.update(importedFileWrapper)
                        self?.isOperatingFile = true
                        NSDocumentController.shared.currentDocument?.save(self)
                        self?.updateProjectInspector()
                    }
                }
            }
        })
    }
    /// name operation: rename, newfile, newfolder
    @IBAction func newFileToProject(_ sender: Any) {
        // get parent node
        // 获取父节点
        let parentNode: FileWrapper?
        let row = self.projectInspector.selectedRow
        // 没有节点被选中时，默认增加到根节点
        if row < 0 {
            parentNode = self.project?.filewrappers
        }
        else {
            // 节点被选中，获取该节点对应的数据对象
            parentNode = self.projectInspector.item(atRow: row) as? FileWrapper
        }
        let sb = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
        let getNameVC = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Get Name View Controller")) as! GetNameViewController
        getNameVC.parentVC = self
        if let senderName = (sender as? NSMenuItem)?.title {
            switch senderName {
            case "New File":
                getNameVC.fileOperation = .newFile
            case "New Folder":
                getNameVC.fileOperation = .newFolder
            case "Rename":
                getNameVC.fileOperation = .rename
            default:
                return
            }
        }
        if let keys = parentNode?.fileWrappers?.keys {
            for key in keys {
                getNameVC.childNames.append(key)
            }
        }
        var grandParent: FileWrapper!
        if let fileWrapper = self.projectInspector.parent(forItem: parentNode) as? FileWrapper {
            grandParent = fileWrapper
        } else {
            grandParent = self.project?.filewrappers
        }
        if let keys = grandParent.fileWrappers?.keys {
            for key in keys {
                getNameVC.parentNames.append(key)
            }
        }
        getNameVC.parentNode = parentNode
        getNameVC.grandNode = grandParent
        self.presentViewControllerAsModalWindow(getNameVC)
    }
    /// delete
    @IBAction func deleteFileInProject(_ sender: Any) {
        let row = self.projectInspector.selectedRow
        // no item selected
        if row < 0 {
            return
        }
        // item selected
        let node = self.projectInspector.item(atRow: row) as! FileWrapper
        var parentNode: FileWrapper
        if let fileWrapper = self.projectInspector.parent(forItem: node) as? FileWrapper {
            parentNode = fileWrapper
        } else {
            parentNode = (self.project?.filewrappers)!
        }
        // prepare panel
        let alert = NSAlert()
        // add OK button
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        // set the alert title
        alert.messageText = NSLocalizedString("Alert", comment: "NSAlert Title")
        alert.informativeText = [NSLocalizedString("Do you really want to delete", comment: "Do you really want to delete"), node.preferredFilename!,"?"].joined(separator: " ")
        alert.alertStyle = .critical
        alert.beginSheetModal(for: self.view.window!, completionHandler:{ [weak self] result in
            if result.rawValue == 1000 {
                self?.doDeleteFileInProject(parent: parentNode, node: node)
            }
        })
    }
    func doDeleteFileInProject(parent: FileWrapper, node: FileWrapper) {
        parent.removeFileWrapper(node)
        self.isOperatingFile = true
        NSDocumentController.shared.currentDocument?.save(self)
        self.updateProjectInspector()
    }
    //****************** About Code Highlight ******************
    func setupHighlightr() {
        // Load the setup of codeTheme
        // if fails, use "xcode" as themeName
        if let path = Bundle.main.path(forResource: "Preference", ofType: "plist") {
            if let themeName = NSDictionary(contentsOfFile: path)?.object(forKey: "CodeTheme") as? String {
                self.themeName = themeName
            }
        }
        // setup Highlightr
        self.hignlightr.setTheme(to: self.themeName)
        // update edit area line number color
        self.setFileTextViewColor()
    }
    /// Setup languageComboBox
    func setupLanguageComboBox() {
        let languageList =
        """
        1c
        abnf
        accesslog
        actionscript
        ada
        apache
        applescript
        arduino
        armasm
        asciidoc
        aspectj
        autohotkey
        autoit
        avrasm
        awk
        axapta
        bash
        basic
        bnf
        brainfuck
        cal
        capnproto
        ceylon
        clean
        clojure
        clojure-repl
        cmake
        coffeescript
        coq
        cos
        cpp
        crmsh
        crystal
        cs
        csp
        css
        d
        dart
        delphi
        diff
        django
        dns
        dockerfile
        dos
        dsconfig
        dts
        dust
        ebnf
        elixir
        elm
        erb
        erlang
        erlang-repl
        excel
        fix
        flix
        fortran
        fsharp
        gams
        gauss
        gcode
        gherkin
        glsl
        go
        golo
        gradle
        groovy
        haml
        handlebars
        haskell
        haxe
        hsp
        htmlbars
        http
        hy
        inform7
        ini
        irpf90
        java
        javascript
        jboss-cli
        json
        julia
        julia-repl
        kotlin
        lasso
        ldif
        leaf
        less
        lisp
        livecodeserver
        livescript
        llvm
        lsl
        lua
        makefile
        markdown
        mathematica
        matlab
        maxima
        mel
        mercury
        mipsasm
        mizar
        mojolicious
        monkey
        moonscript
        n1ql
        nginx
        nimrod
        nix
        nsis
        objectivec
        ocaml
        openscad
        oxygene
        parser3
        perl
        pf
        php
        pony
        powershell
        processing
        profile
        prolog
        protobuf
        puppet
        purebasic
        python
        q
        qml
        r
        rib
        roboconf
        routeros
        rsl
        ruby
        ruleslanguage
        rust
        scala
        scheme
        scilab
        scss
        shell
        smali
        smalltalk
        sml
        sqf
        sql
        stan
        stata
        step21
        stylus
        subunit
        swift
        taggerscript
        tap
        tcl
        tex
        thrift
        tp
        twig
        typescript
        vala
        vbnet
        vbscript
        vbscript-html
        verilog
        vhdl
        vim
        x86asm
        xl
        xml
        xquery
        yaml
        zephir
        """
        let languages = languageList.components(separatedBy: .newlines)
        self.languageComboBox.removeAllItems()
        self.languageComboBox.addItems(withObjectValues: languages)
    }
    /// Color code with new language
    @IBAction func selectLanguageAction(_ sender: Any) {
        if let newLanguage = (sender as? NSComboBox)?.stringValue {
            self.editArea.textStorage?.setAttributedString(self.hignlightr.highlight(self.editArea.string, as: newLanguage)!)
        }
    }
    /// Invoke by setupHighlightr and Preference
    func setFileTextViewColor(){
        if let color = self.hignlightr.theme.themeBackgroundColor {
            self.editArea.backgroundColor = color
            self.editArea.gutterBackgroundColor = color
            let r = color.redComponent
            let g = color.greenComponent
            let b = color.blueComponent
            if (r + g + b) / 3.0 > 0.5 {
                self.editArea.gutterForegroundColor = NSColor.darkGray
                self.editArea.insertionPointColor = NSColor.darkGray
            } else {
                self.editArea.gutterForegroundColor = NSColor.white
                self.editArea.insertionPointColor = NSColor.white
            }
            self.editArea.textStorage?.setAttributedString(self.hignlightr.highlight(self.editArea.string, as: self.fileOnShow?.fileLanguage, fastRender: true)!)
            self.editArea.needsDisplay = true
        }
    }
}

extension DocumentViewController: NSOutlineViewDataSource {
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
            if let filewrappers = self.project?.filewrappers {
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
            if let filewrappers = self.project?.filewrappers {
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

extension DocumentViewController: NSOutlineViewDelegate {
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
     Save file when selection will be changed
    */
    func outlineViewSelectionIsChanging(_ notification: Notification) {
        if self.checkFileModification() {
            NSDocumentController.shared.currentDocument?.save(self)
            self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.reloadProjectInspector), userInfo: nil, repeats: false)
        }
    }
    @objc func reloadProjectInspector() {
        self.projectInspector.reloadData()
    }
    /**
     Check if fileOnShow should be saved
    */
    func checkFileModification() -> Bool {
        var parentFileWrapper: FileWrapper!
        if let fileWrapper = self.projectInspector.parent(forItem: self.fileOnShow) as? FileWrapper {
            parentFileWrapper = fileWrapper
        } else {
            // fileOnShow is in root
            parentFileWrapper = self.project?.filewrappers
        }
        if let fileWrapperToSave = self.fileOnShow {
            if let originalFileString = fileWrapperToSave.regularFileString {
                if originalFileString != self.editArea.string {
                    // content is different
                    if let newFileData = self.editArea.string.data(using: .utf8) {
                        // update the file
                        parentFileWrapper.update(withContents: newFileData, preferredName: fileWrapperToSave.preferredFilename!)
                        return true
                    }
                }
            }
        }
        return false
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
                        self.projectInspector.expandItem(self.projectInspector.item(atRow: row))
                    }
                }
            } else {
                if let fileData = model.regularFileContents {
                    if let fileString = String(data: fileData, encoding: String.Encoding.utf8) {
                        // show the file
                        self.editArea.textStorage?.setAttributedString(self.hignlightr.highlight(fileString, as: model.fileLanguage)!)
                        self.fileOnShow = model
                    } else {
                        self.editArea.string = NSLocalizedString("Fail to open ", comment: "Fail to open ") + "\(model.preferredFilename!)" + NSLocalizedString("\nUnsupported type!", comment: "\nUnsupported type!")
                    }
                } else {
                    self.editArea.string = NSLocalizedString("Fail to open ", comment: "Fail to open ") + "\(model.preferredFilename!)" + NSLocalizedString("\nUnsupported type!", comment: "\nUnsupported type!")
                }
            }
        }
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        let row = self.projectInspector.selectedRow
        if row < 1 {
            switch menuItem.title {
            case "Import File":
                return true
            case "New Folder":
                return true
            case "New File":
                return true
            case "Rename":
                return false
            case "Delete":
                return false
            default:
                return false
            }
        } else {
            if let fileWrapper = self.projectInspector.item(atRow: row) as? FileWrapper {
                if fileWrapper.isDirectory {
                    switch menuItem.title {
                    case "Import File":
                        return true
                    case "New Folder":
                        return true
                    case "New File":
                        return true
                    case "Rename":
                        return true
                    case "Delete":
                        return true
                    default:
                        return false
                    }
                } else {
                    switch menuItem.title {
                    case "Import File":
                        return false
                    case "New Folder":
                        return false
                    case "New File":
                        return false
                    case "Rename":
                        return true
                    case "Delete":
                        return true
                    default:
                        return false
                    }
                }
            } else {
                return false
            }
        }
    }
}

extension DocumentViewController: NSSplitViewDelegate {
    
    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if subview == splitView.subviews[0] {
            return true
        } else {
            return false
        }
    }
    
    func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 {
            // side panel
            return 300
        } else {
            return 2000
        }
    }
    
    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 {
            // side panel
            return 150
        } else {
            return 300
        }
    }
    
    func splitView(_ splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        return true
    }
    
    func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        return true
    }
}

extension DocumentViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        let cursorPos = self.editArea.selectedRange()
        self.editArea.textStorage?.setAttributedString(self.hignlightr.highlight(self.editArea.string, as: self.fileOnShow?.fileLanguage)!)
        self.editArea.setSelectedRange(cursorPos)
    }
}
