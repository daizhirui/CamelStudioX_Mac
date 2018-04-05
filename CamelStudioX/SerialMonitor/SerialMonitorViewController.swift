//
//  SerialMonitorViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import LineNumberTextView

class SerialMonitorViewController: NSViewController {

    @IBOutlet weak var switchButton: NSButton!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var textView: SerialScreenView!
    @objc let serialController = SerialController()
    @IBOutlet weak var inputBox: NSTextField!
    @IBOutlet weak var addressBox: NSTextField!
    @IBOutlet weak var endingPopUpButton: NSPopUpButton!
    
    let moreConfigViewController: SerialMonitorConfigViewController = {
        let sb = NSStoryboard.init(name: NSStoryboard.Name("SerialMonitor"), bundle: nil)
        return sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SerialMonitorConfigViewController")) as! SerialMonitorConfigViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ***** Setup SerialController ******
        self.serialController.switchButton = self.switchButton
        self.serialController.screen = self.textView
        self.serialController.scrollControll = self.scrollView
        // ***** Setup TextView ********
        self.textView.lineNumberBackgroundColor = NSColor.white
        self.textView.lineNumberForegroundColor = NSColor.gray
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataForSerialScreen), name: NSNotification.Name.userInput, object: self.textView)
            // 关闭智能引号功能, 拼写检查，拼写纠正, 语法检查
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isContinuousSpellCheckingEnabled = false
        self.textView.isAutomaticSpellingCorrectionEnabled = false
        self.textView.isGrammarCheckingEnabled = false
        // ****** Setup Config View Controller
        self.moreConfigViewController.parentVC = self
        // ******* Setup Ending *********
        self.endingPopUpButton.addItems(withTitles: ["<CR>", "<LF>", "<CR><LF>"])
        self.endingPopUpButton.selectItem(at: 0)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.serialController.serialPort?.close()
        if let wc = self.view.window?.windowController {
            wc.close()
        }
    }
    // ************ Serial Setup *************
    @IBAction func toggelSerialPort(_ sender: Any) {
        self.serialController.openOrClosePort()
    }
    @IBAction func moreSerialControllerConfig(_ sender: Any) {
        self.presentViewControllerAsSheet(self.moreConfigViewController)
    }
    
    // ************* Communication **************
    @objc func sendDataForSerialScreen() {
        self.serialController.sendData(self.textView.userInput)
    }
    var ending = "\r"
    @IBAction func selectEnding(_ sender: NSPopUpButton) {
        switch sender.title {
        case "<CR>":
            self.ending = "\r"
        case "<LF>":
            self.ending = "\n"
        case "<CR><LF>":
            self.ending = "\r\n"
        default:
            self.ending = "\r"
        }
    }
    @IBAction func sendData(_ sender: Any) {
        self.serialController.sendData(self.inputBox.stringValue)
        self.inputBox.stringValue = ""
    }
    @IBAction func sendDataWithEnding(_ sender: Any) {
        self.serialController.sendData(self.inputBox.stringValue + self.ending)
        self.inputBox.stringValue = ""
    }
    @IBAction func clearScreen(_ sender: Any) {
        self.textView.string = ""
    }
    @IBAction func jumpToAddress(_ sender: Any) {
        self.serialController.sendData("3")
        sleep(1)
        self.serialController.sendData("\(self.addressBox.stringValue)\n")
    }
    // *********** Save Result ************
    var logFileURL: URL!
    @IBAction func saveAction(_ sender: NSButton) {
        if let url = self.logFileURL {
            let text = self.textView.string
            _ = try? text.write(to: url, atomically: true, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        } else {
            self.saveAsAction(sender)
        }
    }
    @IBAction func saveAsAction(_ sender: NSButton) {
        // 获取文本框内的内容
        let text = self.textView.string
        // 创建面板
        let saveFileDlg = NSSavePanel()
        saveFileDlg.title = NSLocalizedString("Save Log File", comment: "Save Log File")
        // 显示提示文字在顶部
        saveFileDlg.allowedFileTypes = ["txt"]
        // 默认的文件名
        saveFileDlg.nameFieldStringValue = NSLocalizedString("MyUntitled", comment: "MyUntitled")
        // 启动面板
        // completionHandler 为面板点击 OK 时执行的操作，此处为保存操作
        saveFileDlg.begin(completionHandler: { [weak self] result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self?.logFileURL = saveFileDlg.url
                _ = try? text.write(to: self!.logFileURL, atomically: true, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            }
        })
    }
    // ************* Data Analyzer **************
    var dataAnalyzerWindowController: NSWindowController!
    var dataAnalyzerViewController: DataAnalyzerViewController!
    @IBAction func dataAnalyzerAction(_ sender: Any) {
        if self.dataAnalyzerWindowController != nil {
             self.dataAnalyzerViewController.dataTextView.string = self.serialController.receivedDataBuffer
            self.dataAnalyzerWindowController.showWindow(self)
        } else {
            let sb = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "DataAnalyzer"), bundle: nil)
            let wc = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DataAnalyzerWindowController")) as? NSWindowController
            self.dataAnalyzerViewController = wc?.contentViewController as? DataAnalyzerViewController
            self.dataAnalyzerViewController.dataTextView.string = self.serialController.receivedDataBuffer
            self.dataAnalyzerWindowController = wc
            self.dataAnalyzerWindowController.showWindow(self)
        }
    }
    
}
