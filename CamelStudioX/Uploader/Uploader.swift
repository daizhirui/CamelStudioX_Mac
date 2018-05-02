//
//  Uploader.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

let timeoutDuration = 5.0

public enum UploadStage: Int {
    case getBinary          = 1
    case checkRootSpace     = 2
    case setBaudrate19200   = 3
    case eraseFlash         = 4
    case sendBinary         = 5
    case setBaudrate9600    = 6
    case showResult         = 7
}

extension NSNotification.Name {
    static let uploadingFailed = NSNotification.Name("uploadingFailed")
    static let uploadingSucceeded = NSNotification.Name("uploadingSucceeded")
    static let uploadingCancelled = NSNotification.Name("uploadingCancelled")
    static let updatedProgress = NSNotification.Name("updatedProgress")
}

class Uploader: NSObject {
    /// use the default serial port manager
    @objc let serialPortManager = ORSSerialPortManager.shared()
    /**
     an ORSSerialPort instance to store the current used serial port
     When the serial port selected is changed, the didSetter will release the old one
     and connect the delegate to the new one automatically
     */
    @objc var serialPort: ORSSerialPort? {
        willSet {
            if let port = serialPort {
                port.close()
                port.delegate = nil
            }
        }
        didSet {
            if let port = serialPort {
                port.baudRate = 9600
                port.delegate = self
                port.open()
                self.recentSerialPort = port
            }
        }
    }
    var recentSerialPort: ORSSerialPort?
    var receivedResponse: String = ""
    /// indicate if is uploading
    @objc var uploadFlag = false
    /// indicate the progress
    @objc var progressValue = 0.0
    @objc var progressInfo = ""
    /// Record the current upload stage
    var currentUploadStage = UploadStage.init(rawValue: 1)!
    /// url to get the binary
    var binaryURL: URL!
    /// Store the binary data to upload
    var binaryData: Data!
    var targetAddress = "10000000"
    var uploadResult = ""
//    override init() {
//        super.init()
//    }
    /**
     Because serial device may react slowly, we need to wait for it.
     */
    func waitForChip() {
        usleep(250000)  // 0.25 s
    }
    func startUpload() {
        self.serialPort?.open()
        self.uploadFlag = true
    }
    
    @objc func uploadStageControl(_ aNotification: Notification?) {
        myDebug(">>>>>>> UPLOAD STAGE CONTROL: \(self.currentUploadStage)")
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
    
    func checkRootSpace() {
        if self.uploadFlag {
            self.serialPort?.baudRate = 9600
            self.progressValue = 10.0
            self.progressInfo = NSLocalizedString("Check root space...", comment: "Check root space...")
            self.postProgressUpdate()
            self.sendCommandToBoard(command: "\n", responsePrefix: nil, responseSuffix: "CamelStudio", bufferSize: 270, userInfo: "checkRootSpace")
            // next stage
            self.currentUploadStage = .setBaudrate19200
        }
    }
    /**
     Used before erase the flash
    */
    func setChipBaudrate19200() {
        self.progressValue = 20.0
        self.progressInfo = NSLocalizedString("Setting the baudrate to 19200 ...", comment: "Setting the baudrate to 19200 ...")
        self.postProgressUpdate()
        self.sendCommandToBoard(command: "1", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send 1f800702\n")
    }
    
    func eraseFlash() {
        self.progressValue = 30.0
        self.progressInfo = NSLocalizedString("Erasing the flash ...", comment: "Erasing the flash ...")
        self.postProgressUpdate()
        self.sendCommandToBoard(command: "1", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send 10300000\n")
    }
    
    func sendBinary() {
        self.progressValue = 50.0
        self.progressInfo = NSLocalizedString("Uploading the binary ...", comment: "Uploading the binary ...")
        self.postProgressUpdate()
        self.sendCommandToBoard(command: "5", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send targetAddress")
    }
    
    /**
     Used after uploading the binary
     */
    func setChipBaudrate9600() {
        self.progressValue = 99.0
        self.progressInfo = NSLocalizedString("Setting the baudrate to 9600 ...", comment: "Setting the baudrate to 9600 ...")
        self.postProgressUpdate()
        let startIndex = self.receivedResponse.startIndex
        let endIndex = self.receivedResponse.index(startIndex, offsetBy: self.receivedResponse.count - 5)
        self.uploadResult = String(self.receivedResponse[startIndex..<endIndex])
        self.sendCommandToBoard(command: "1", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send 1f800702\n")
    }
    
    func cancelUpload() {
        myDebug("RESET UPLOADER!!")
        self.uploadFlag = false
        self.currentUploadStage = UploadStage.init(rawValue: 1)!
        self.binaryData = nil
        self.serialPort?.baudRate = 9600
        self.serialPort?.close()
        myDebug("CURRENT_UPLOAD_STAGE RESET TO:\(self.currentUploadStage)")
    }
    
    func timeout() {
        myDebug("WARNING!! TIMEOUT!!")
        switch self.currentUploadStage {
        case .setBaudrate19200:
            _ = showAlertWindow(with: NSLocalizedString("Please set the chip to root space!", comment: "Please set the chip to root space!"))
        case .eraseFlash:
            _ = showAlertWindow(with: NSLocalizedString("Baudrate 19200 setup failed!", comment: "Baudrate 19200 setup failed!"))
        case .sendBinary:
            _ = showAlertWindow(with: NSLocalizedString("Flash erasing failed!", comment: "Flash erasing failed!"))
        case .setBaudrate9600:
            _ = showAlertWindow(with: NSLocalizedString("Binary Uploading failed!", comment: "Binary Uploading failed!"))
        case .showResult:
            _ = showAlertWindow(with: NSLocalizedString("Baudrate 9600 setup maybe fail! Please reset the chip!", comment: "Baudrate 9600 setup maybe fail! Please reset the chip!"))
            self.uploadSucceeded()
            return
        default:
            return
        }
        self.uploadFailed()
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

extension Uploader: ORSSerialPortDelegate{
    
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.uploadFailed()
        _ = showAlertWindow(with: NSLocalizedString("Serial Port Disconnected, Uploading Failed", comment: "Serial Port Disconnected, Uploading Failed"))
    }
    
    /// response to serialPort Error
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        let alertMessage = NSLocalizedString("Serial Port", comment: "Serial Port") + "\(serialPort) " + NSLocalizedString("encountered an error: ", comment: "encountered an error: ") + "\(error)"
        _ = showAlertWindow(with: alertMessage)
        self.serialPort = nil
    }
    
    /// send command to board
    func sendCommandToBoard(command: String, responsePrefix: String?, responseSuffix: String?, bufferSize: UInt, userInfo: Any?) {
        let responseDescriptor = ORSSerialPacketDescriptor(prefixString: responsePrefix, suffixString: responseSuffix, maximumPacketLength: bufferSize, userInfo: userInfo)
        self.sendCommandToBoard(command: command, responseDescriptor: responseDescriptor, userInfo: userInfo)
    }
    /// send command to board
    func sendCommandToBoard(command: String, responseDescriptor: ORSSerialPacketDescriptor, userInfo: Any?) {
        let commandData = command.data(using: .ascii)!
        let request = ORSSerialRequest(dataToSend: commandData,
                                       userInfo: userInfo,
                                       timeoutInterval: timeoutDuration,
                                       responseDescriptor: responseDescriptor)
        self.serialPort?.send(request)
    }
    /**
     Send data through a selected serial port.
     
     - parameters:
     - aString: Content to send
     - encodingMethod: Method to encode aString, default .utf8
     */
    func sendData(_ aString: String, using encodingMethod: String.Encoding = .utf8) {
        if let data = aString.data(using: encodingMethod) {
            self.serialPort?.send(data)
        } else {
            _ = showAlertWindow(with: NSLocalizedString("Fail to send", comment: "Fail to send")+" \(aString)")
        }
    }
    
    /// parsing the response
    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        myDebug("Request Number = \(serialPort.queuedRequests.count)")
        if let response = String(data: responseData, encoding: .utf8) {
            self.receivedResponse = response
            myDebug(response)
        }
        if let userInfo = request.userInfo as? String {
            myDebug(userInfo)
            switch userInfo {
            case "checkRootSpace", "setChipBaudrate19200", "eraseFlash", "sendBinary", "setChipBaudrate9600":
                self.uploadStageControl(nil)
            case "send 1f800702\n":
                if self.currentUploadStage == .setBaudrate19200 {
                    self.sendCommandToBoard(command: "1f800702\n", responsePrefix: nil, responseSuffix: "Value in hex>", bufferSize: 40, userInfo: "send 00001000\n")
                } else if self.currentUploadStage == .setBaudrate9600 {
                    self.sendCommandToBoard(command: "1f800702\n", responsePrefix: nil, responseSuffix: "Value in hex>", bufferSize: 40, userInfo: "send 00000000\n")
                }
            case "send 00001000\n":
                self.sendData("00001000\n")
                self.waitForChip()
                self.serialPort?.baudRate = 19200
                self.sendCommandToBoard(command: "\n", responsePrefix: nil, responseSuffix: "CamelStudio", bufferSize: 270, userInfo: "setChipBaudrate19200")
                self.currentUploadStage = .eraseFlash
            case "send 00000000\n":
                self.sendData("00000000\n")
                self.waitForChip()
                self.serialPort?.baudRate = 9600
                self.waitForChip()
                self.sendCommandToBoard(command: "\n", responsePrefix: nil, responseSuffix: "CamelStudio", bufferSize: 270, userInfo: "setChipBaudrate9600")
                self.currentUploadStage = .showResult
            case "send 10300000\n":
                self.sendCommandToBoard(command: "10300000\n", responsePrefix: nil, responseSuffix: "Value in hex>", bufferSize: 40, userInfo: "send 1\n")
            case "send 1\n":
                self.sendCommandToBoard(command: "1\n", responsePrefix: nil, responseSuffix: "CamelStudio", bufferSize: 40, userInfo: "send 4")
            case "send 4":
                self.sendCommandToBoard(command: "4", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send 10000000\n")
            case "send 10000000\n":
                if self.currentUploadStage == .eraseFlash {
                    self.sendCommandToBoard(command: "10000000\n", responsePrefix: nil, responseSuffix: "Count in hex>", bufferSize: 40, userInfo: "send 64\n")
                }
            case "send 64\n":
                self.sendCommandToBoard(command: "64\n", responsePrefix: nil, responseSuffix: "FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF", bufferSize: 200, userInfo: "eraseFlash")
                self.currentUploadStage = .sendBinary
            case "send targetAddress":
                self.sendCommandToBoard(command: self.targetAddress+"\n", responsePrefix: nil, responseSuffix: "Waiting for binary image linked at 10000000", bufferSize: 200, userInfo: "send binary")
            case "send binary":
                self.serialPort?.send(self.binaryData)
                self.waitForChip()
                self.sendData("1")
                self.waitForChip()
                self.sendCommandToBoard(command: "1f800702\n", responsePrefix: "p1 final index", responseSuffix: "Menu", bufferSize: 120, userInfo: "sendBinary")
                self.currentUploadStage = .setBaudrate9600
            default: return
            }
        }
        
    }
    
    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        myDebug(request.userInfo as! String)
        self.timeout()
    }
}
