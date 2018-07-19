//
//  SerialMonitorViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import LineNumberTextView
import ORSSerial

class SerialMonitorViewController: NSViewController {

    @IBOutlet weak var switchButton: NSButton!
    @IBOutlet weak var portBox: NSPopUpButton!
    @IBOutlet weak var baudrateBox: NSPopUpButton!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var textView: SerialScreenView!
    @IBOutlet weak var inputBox: NSTextField!
    @IBOutlet weak var addressBox: NSTextField!
    @IBOutlet weak var endingPopUpButton: NSPopUpButton!
    
    @objc let serialController = SerialController()
    
    let serialConfigViewController: SerialMonitorConfigViewController = {
        let sb = NSStoryboard.init(name: NSStoryboard.Name("SerialMonitor"), bundle: nil)
        return sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SerialMonitorConfigViewController")) as! SerialMonitorConfigViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ***** Setup SerialController ******
        self.serialController.switchButton = self.switchButton
        if let portName = SerialController.recentSerialPort?.name {
            self.portBox.selectItem(withTitle: portName)
            self.serialController.serialPort = SerialController.recentSerialPort
            self.baudrateBox.selectItem(withTitle: "9600")
            self.serialController.serialPort?.baudRate = 9600
        } else if let portName = UserDefaults.standard.object(forKey: "recentSerialPort") as? String {
            for possiblePort in self.serialController.serialPortManager.availablePorts {
                if possiblePort.name == portName {
                    self.portBox.selectItem(withTitle: portName)
                    self.serialController.serialPort = possiblePort
                    self.baudrateBox.selectItem(withTitle: "9600")
                    self.serialController.serialPort?.baudRate = 9600
                }
            }
        }
        self.serialController.screen = self.textView
        //self.serialController.scrollControll = self.scrollView
        // ***** Setup TextView ********
        self.textView.lineNumberBackgroundColor = NSColor.white
        self.textView.lineNumberForegroundColor = NSColor.gray
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataForSerialScreen), name: NSNotification.Name.userInput, object: self.textView)
        // turn off some smart functions or automatic functions of nstextview
        self.textView.turnOffAllSmartOrAutoFunctionExceptLinkDetection()
        // ****** Setup Config View Controller
        self.serialConfigViewController.parentVC = self
        // ******* Setup Ending *********
        self.endingPopUpButton.addItems(withTitles: ["<CR>", "<LF>", "<CR><LF>"])
        self.endingPopUpButton.selectItem(at: 0)
    }
    
    override func viewWillAppear() {
        guard let baudrateValue = self.serialController.serialPort?.baudRate else { return }
        self.baudrateBox.selectItem(withTitle: "\(baudrateValue)")
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.serialController.serialPort?.close()
        self.serialController.serialPort?.delegate = nil
        self.serialController.serialPort = nil
        if let wc = self.view.window?.windowController {
            wc.close()
        }
    }
    // ************ Serial Setup *************
    @IBAction func setBaudrate(_ sender: NSPopUpButton) {
        self.serialController.serialPort?.baudRate = NSNumber(value: Int(sender.selectedItem!.title)!)
    }
    @IBAction func toggelSerialPort(_ sender: Any) {
        self.serialController.openOrClosePort()
    }
    @IBAction func moreSerialControllerConfig(_ sender: Any) {
        self.presentViewControllerAsSheet(self.serialConfigViewController)
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
            do {
                _ = try text.write(to: url, atomically: true, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            } catch let error as NSError {
                _ = InfoAndAlert.shared.showAlertWindow(with: error.localizedDescription)
            }
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
