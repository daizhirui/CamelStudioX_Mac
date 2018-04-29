//
//  Uploader.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

public enum UploadStage: Int {
    case getBinary          = 1
    case checkRootSpace     = 2
    case setBaudrate19200   = 3
    case eraseFlash         = 4
    case sendBinary         = 5
    case getResult          = 6
    case setBaudrate9600    = 7
    case showResult         = 8
}

extension NSNotification.Name {
    static let uploadingFailed = NSNotification.Name("uploadingFailed")
    static let uploadingSucceeded = NSNotification.Name("uploadingSucceeded")
    static let uploadingCancelled = NSNotification.Name("uploadingCancelled")
    static let updatedProgress = NSNotification.Name("updatedProgress")
    static let failToOpenPort = NSNotification.Name("failToOpenPort")
}

class Uploader: NSObject {
    /// indicate if is uploading
    @objc var uploadFlag = false
    /// indicate the progress
    @objc var progressValue = 0.0
    @objc var progressInfo = ""
    /// A serial controller used to upload
    @objc let serialController = SerialController()
    /// Record the current upload stage
    var currentUploadStage = UploadStage.init(rawValue: 1)!
    /// url to get the binary
    var binaryURL: URL!
    /// Store the binary data to upload
    var binaryData: Data!
    var targetAddress = "10000000"
    var uploadResult = ""
    override init() {
        super.init()
        self.serialController.uploader = self
    }
    /**
     Because serial device may react slowly, we need to wait for it.
     */
    func waitForChip() {
        sleep(1)
    }
    func startUpload() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadFailed), name: NSNotification.Name.failToOpenPort, object: self.serialController)
        self.uploadFlag = true
    }
    
    @objc func uploadStageControl(_ aNotification: Notification?) {
        myDebug(">>>>>>> UPLOAD STAGE CONTROL: \(self.currentUploadStage)")
        myDebug("recentReceivedDataSize = \(self.serialController.recentReceivedDataSize)")
        myDebug("Actual size = \(self.serialController.recentReceivedData.count)")
        myDebug(">> recentReceivedData content:")
        myDebug(self.serialController.recentReceivedData)
        myDebug(">> receivedDataBuffer content:")
        myDebug(self.serialController.receivedDataBuffer)
        myDebug("\n\n")
        switch self.currentUploadStage {
        case .getBinary:
            self.getBinary()
        case .checkRootSpace:
            self.checkRootSpace()
        case .setBaudrate19200:
            self.setChipBaudrate19200()
        case .eraseFlash:
            self.eraseFlash()
        case .sendBinary:
            self.sendBinary()
        case .getResult:
            self.getResult()
        case .setBaudrate9600:
            self.setChipBaudrate9600()
        case .showResult:
            self.uploadSucceeded()
        }
    }
    
    func getBinary() {
        if FileManager.default.fileExists(atPath: self.binaryURL.relativePath) {
            if let data = try? Data(contentsOf: self.binaryURL) {
                self.binaryData = data
                // next stage
                self.currentUploadStage = .checkRootSpace
                self.uploadStageControl(nil)
            } else {
                _ = showAlertWindow(with: NSLocalizedString("Failed to get the binary", comment: "Failed to get the binary"))
                self.uploadFailed()
            }
        } else {
            _ = showAlertWindow(with: NSLocalizedString("Failed to get the binary", comment: "Failed to get the binary"))
            self.uploadFailed()
        }
    }
    
    func setupSerialControllerForStageCheck(dataSize: Int, nextStageSignal: String) {
        self.serialController.receivedDataBuffer = ""
        self.serialController.recentReceivedData = ""
        self.serialController.recentReceivedDataSize = dataSize
        self.serialController.nextStageSignal = nextStageSignal
        self.serialController.checkFlag = true
    }
    
    func checkRootSpace() {
        if let serialPort = self.serialController.serialPort {
            if serialPort.isOpen != true {
                serialPort.open()
            }
            // if open port failed, uploadFlag will be false
            if self.uploadFlag {
                serialPort.baudRate = 9600
                self.progressValue = 10.0
                self.progressInfo = NSLocalizedString("Check root space...", comment: "Check root space...")
                self.postProgressUpdate()
                self.setupSerialControllerForStageCheck(dataSize: 270, nextStageSignal: "CamelStudio")
                self.serialController.sendData("\n")
                // next stage
                self.currentUploadStage = .setBaudrate19200
                self.startTimer()
            }
        } else {
            _ = showAlertWindow(with: NSLocalizedString("Failed to open serial port", comment: "Failed to open serial port"))
            self.uploadFailed()
        }
    }
    /**
     Used before erase the flash
    */
    func setChipBaudrate19200() {
        self.timer?.invalidate()    // stop timer
        self.progressValue = 20.0
        self.progressInfo = NSLocalizedString("Setting the baudrate to 19200 ...", comment: "Setting the baudrate to 19200 ...")
        self.postProgressUpdate()
        self.serialController.sendData("1")
        self.waitForChip()
        self.serialController.sendData("1f800702\n")
        self.waitForChip()
        self.serialController.sendData("00001000\n")
        self.waitForChip()
        self.serialController.serialPort?.baudRate = 19200       // set controller to 19200!!!
        self.setupSerialControllerForStageCheck(dataSize: 270, nextStageSignal: "CamelStudio")
        self.serialController.sendData("\n")
        // next stage
        self.currentUploadStage = .eraseFlash
        self.startTimer()
    }
    
    func eraseFlash() {
        self.timer?.invalidate()    // stop timer
        self.progressValue = 30.0
        self.progressInfo = NSLocalizedString("Erasing the flash ...", comment: "Erasing the flash ...")
        self.postProgressUpdate()
        self.serialController.sendData("1")
        self.waitForChip()
        self.serialController.sendData("10300000\n")
        self.waitForChip()
        self.serialController.sendData("1\n")
        self.waitForChip()
        self.serialController.sendData("4")
        self.waitForChip()
        self.serialController.sendData("10000000\n")
        self.waitForChip()
        self.setupSerialControllerForStageCheck(dataSize: 800, nextStageSignal: "FFFFFFFF")
        self.serialController.sendData("64\n")
        // next stage
        self.currentUploadStage = .sendBinary
        self.startTimer()
    }
    
    func sendBinary() {
        self.timer?.invalidate()    // stop timer
        self.progressValue = 50.0
        self.progressInfo = NSLocalizedString("Uploading the binary ...", comment: "Uploading the binary ...")
        self.postProgressUpdate()
        self.serialController.sendData("5")
        self.waitForChip()
        self.serialController.sendData(self.targetAddress+"\n")
        self.waitForChip()
        self.serialController.serialPort?.send(self.binaryData)
        // prepare to receive response
        self.setupSerialControllerForStageCheck(dataSize: 900, nextStageSignal: "p1 final")
        self.waitForChip()
        self.serialController.sendData("1")
        self.waitForChip()
        self.serialController.sendData("1f800702\n")
        self.waitForChip()
        // next stage
        self.currentUploadStage = .getResult
        self.startTimer()
    }
    
    func getResult() {
        self.timer?.invalidate()
        self.progressValue = 95.0
        self.progressInfo = NSLocalizedString("Getting the feedback from chip ...", comment: "Getting the feedback from chip ...")
        self.postProgressUpdate()
        self.setupSerialControllerForStageCheck(dataSize: 270, nextStageSignal: "Menu")
        // next stage
        self.currentUploadStage = .setBaudrate9600
        self.startTimer()
    }
    
    /**
     Used after uploading the binary
     */
    func setChipBaudrate9600() {
        self.timer?.invalidate()    // stop timer
        self.progressValue = 99.0
        self.progressInfo = NSLocalizedString("Setting the baudrate to 9600 ...", comment: "Setting the baudrate to 9600 ...")
        self.postProgressUpdate()
        if self.serialController.recentReceivedData.contains("final") {
            var aString = self.serialController.recentReceivedData
            while !aString.hasPrefix("p1") {
                aString.remove(at: aString.startIndex)
            }
            let startIndex = aString.startIndex
            let endIndex = aString.index(startIndex, offsetBy: aString.count - 5)
            self.uploadResult = String(aString[startIndex..<endIndex])
        }
        self.serialController.sendData("1")
        self.waitForChip()
        self.serialController.sendData("1f800702\n")
        self.waitForChip()
        self.serialController.sendData("00000000\n")
        self.waitForChip()
        self.serialController.serialPort?.baudRate = 9600       // set controller to 9600!!!
        self.setupSerialControllerForStageCheck(dataSize: 350, nextStageSignal: "CamelStudio")
        self.serialController.sendData("\n")
        // next stage
        self.currentUploadStage = .showResult
        self.startTimer()
    }
    
    func cancelUpload() {
        myDebug("RESET UPLOADER!!")
        self.timer?.invalidate()
        self.timer = nil
        self.uploadFlag = false
        self.currentUploadStage = UploadStage.init(rawValue: 1)!
        self.binaryData = nil
        self.serialController.serialPort?.baudRate = 9600
        self.serialController.serialPort?.close()
        self.serialController.recentReceivedDataSize = 270
        self.serialController.checkFlag = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.failToOpenPort, object: self.serialController)
        myDebug("CURRENT_UPLOAD_STAGE RESET TO:\(self.currentUploadStage)")
    }
    
    var timer: Timer?
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.timeout), userInfo: nil, repeats: false)
    }
    
    @objc func timeout() {
        myDebug("WARNING!! TIMEOUT!!")
        myDebug((UploadStage.init(rawValue: self.currentUploadStage.rawValue - 1)!))
        myDebug("Timer ID = \(String(describing: self.timer?.hashValue))")
        switch self.currentUploadStage {
        case .setBaudrate19200:
            _ = showAlertWindow(with: NSLocalizedString("Please set the chip to root space!", comment: "Please set the chip to root space!"))
        case .eraseFlash:
            _ = showAlertWindow(with: NSLocalizedString("Baudrate 19200 setup failed!", comment: "Baudrate 19200 setup failed!"))
        case .sendBinary:
            _ = showAlertWindow(with: NSLocalizedString("Flash erasing failed!", comment: "Flash erasing failed!"))
        case .getResult:
            _ = showAlertWindow(with: NSLocalizedString("The chip doesn't respond, please reset it manually!", comment: "The chip doesn't respond, please reset it manually!"))
        case .setBaudrate9600:
            _ = showAlertWindow(with: NSLocalizedString("Binary Uploading failed!", comment: "Binary Uploading failed!"))
        case .showResult:
            _ = showAlertWindow(with: NSLocalizedString("Baudrate 9600 setup maybe fail! Please reset the chip!", comment: "Baudrate 9600 setup maybe fail! Please reset the chip!"))
            self.uploadSucceeded()
            self.timer?.invalidate()
            self.timer = nil
            return
        default:
            return
        }
        self.timer?.invalidate()
        self.timer = nil
        self.uploadFailed()
    }
    
    func forwardToNextStage() {
        //NotificationCenter.default.post(name: NSNotification.Name.timeForNextUploadStage, object: self)
    }
    
    @objc func uploadFailed() {
        NotificationCenter.default.post(name: NSNotification.Name.uploadingFailed, object: self)
    }
    
    func uploadSucceeded() {
        self.progressValue = 100.0
        self.progressInfo = NSLocalizedString("Upload succeeded!", comment: "Upload succeeded!")
        NotificationCenter.default.post(name: NSNotification.Name.uploadingSucceeded, object: self)
    }
    
    func postProgressUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name.updatedProgress, object: self)
    }
}
