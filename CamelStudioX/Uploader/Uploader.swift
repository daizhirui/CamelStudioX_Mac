//
//  Uploader.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import ORSSerial

var timeoutDuration = 5.0

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

class Uploader: NSObject, ORSSerialPortDelegate {
    
    /**
     Initalize the super class and add notifications of "Serial ports were connected" and "Serial ports were
     disconnected" to the notification center.
     */
    override init() {
        super.init()
        myDebug("Uploader \(self) is loaded")
        // setup the notification center
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereChanged(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereChanged(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
    }
    
    /// UI Properties
    var viewController: DocumentViewController?
    
    // MARK: - Reaction to Serial Change
    /// Post a notification when a serial device is connected or disconnected.
    @objc func serialPortsWereChanged(_ aNotification: Notification) {
        let title: String
        let changeType: String
        let key: String
        
        if aNotification.name == NSNotification.Name.ORSSerialPortsWereConnected {
            title = "Serial Port Connected"
            changeType = "connected"
            key = ORSConnectedSerialPortsKey
        } else if aNotification.name == NSNotification.Name.ORSSerialPortsWereDisconnected {
            title = "Serial Port Disconnected"
            changeType = "disconnected"
            key = ORSDisconnectedSerialPortsKey
            self.uploadConfigReady = false
        } else {
            return
        }
        
        if let userInfo = aNotification.userInfo {
            if let connectedPorts = userInfo[key] as? [ORSSerialPort] {
                for port in connectedPorts {
                    InfoAndAlert.shared.postNotification(title: title, informativeText: "Serial Port \(port.name) is \(changeType) to your Mac.")
                }
            }
        }
    }
    
    // MARK: - Serial Control Properties
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
                if let lastDelegate = port.delegate as? SerialController {
                    port.close()
                    lastDelegate.serialPort = nil
                    lastDelegate.switchButton?.state = .off
                }
                port.baudRate = 9600
                port.delegate = self
                port.open()
                self.recentSerialPort = port
                UserDefaults.standard.set(port.name as Any, forKey: "recentSerialPort")
                if let vc = self.viewController {
                    vc.serialPortStateLabel.stringValue = "\(vc.project!.chipType.rawValue) at /dev/cu.\(port.name)"
                }
            } else {
                self.uploadConfigReady = false
            }
        }
    }
    /// To remember the serial port choosed recently.
    var recentSerialPort: ORSSerialPort?
    /// Response from the serial port.
    var receivedResponse: String = ""
    
    // MARK: - Upload Control Properties
    /// Indicate if is uploading
    @objc var uploadFlag = false
    /// Indicate if the configuration of port and binary is ready
    var uploadConfigReady = false
    /// Indicate the progress
    @objc var progressValue = 0.0
    /// Indicate the current upload stage
    @objc var progressInfo = ""
    /// Record the current upload stage
    var currentUploadStage = UploadStage.init(rawValue: 1)!
    /// URL to get the binary
    var binaryURL: URL!
    /// Store the binary data to upload
    var binaryData: Data!
    /// Target Address
    var targetAddress = "10000000"
    /// Upload Result from the board
    var uploadResult = ""

    // MARK: - Upload Control Functions
    /**
     Because serial device may react slowly, we need to wait for it.
     */
    func waitForChip() {
        usleep(250000)  // 0.25 s
    }
    /// Open the serial port for uploading
    func startUpload() {
        self.serialPort?.open()
        //self.uploadFlag = true    modified by DocumentWindowsController already
        self.serialPort?.delegate = self
    }
    /// Upload Control Entrance
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
    /// Upload Control Function for getting the binary.
    func getBinary() {
        if FileManager.default.fileExists(atPath: self.binaryURL.relativePath) {
            if let data = try? Data(contentsOf: self.binaryURL) {
                self.binaryData = data
                //timeoutDuration = Double(self.binaryData.count / 1000)
                // next stage
                self.currentUploadStage = .checkRootSpace
                self.uploadStageControl(nil)
            } else {
                _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Failed to get the binary", comment: "Failed to get the binary"))
                self.uploadConfigReady = false
                self.uploadFailed()
            }
        } else {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Failed to get the binary", comment: "Failed to get the binary"))
            self.uploadConfigReady = false
            self.uploadFailed()
        }
    }
    /// Upload Control Function for checking if the board is set to root space.
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
    /// Upload Control Function for setting the baudrate of the chip to 19200.
    func setChipBaudrate19200() {
        self.progressValue = 20.0
        self.progressInfo = NSLocalizedString("Setting the baudrate to 19200 ...", comment: "Setting the baudrate to 19200 ...")
        self.postProgressUpdate()
        self.sendCommandToBoard(command: "1", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send 1f800702\n")
    }
    /// Upload Control Function for erasing the flash of the chip.
    func eraseFlash() {
        self.progressValue = 30.0
        self.progressInfo = NSLocalizedString("Erasing the flash ...", comment: "Erasing the flash ...")
        self.postProgressUpdate()
        self.sendCommandToBoard(command: "1", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send 10300000\n")
    }
    /// Upload Control Function for sending the binary.
    func sendBinary() {
        self.progressValue = 50.0
        self.progressInfo = NSLocalizedString("Uploading the binary ...", comment: "Uploading the binary ...")
        self.postProgressUpdate()
        self.sendCommandToBoard(command: "5", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send targetAddress")
    }
    /// Upload Control Function for setting the baudrate of the chip to 9600.
    func setChipBaudrate9600() {
        self.progressValue = 99.0
        self.progressInfo = NSLocalizedString("Setting the baudrate to 9600 ...", comment: "Setting the baudrate to 9600 ...")
        self.postProgressUpdate()
        let startIndex = self.receivedResponse.startIndex
        let endIndex = self.receivedResponse.index(startIndex, offsetBy: self.receivedResponse.count - 5)
        self.uploadResult = String(self.receivedResponse[startIndex..<endIndex])
        self.sendCommandToBoard(command: "1", responsePrefix: nil, responseSuffix: "Address in hex>", bufferSize: 20, userInfo: "send 1f800702\n")
    }
    /// Cancel uploading, reset the uploader.
    func cancelUpload() {
        myDebug("RESET UPLOADER!!")
        self.uploadFlag = false
        self.currentUploadStage = UploadStage.init(rawValue: 1)!
        self.binaryData = nil
        self.serialPort?.baudRate = 9600
        self.serialPort?.close()
        myDebug("CURRENT_UPLOAD_STAGE RESET TO:\(self.currentUploadStage)")
    }
    /// Timeout Process
    func timeout() {
        myDebug("WARNING!! TIMEOUT!!")
        switch self.currentUploadStage {
        case .setBaudrate19200:
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Please set the chip to root space!", comment: "Please set the chip to root space!"))
        case .eraseFlash:
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Baudrate 19200 setup failed!", comment: "Baudrate 19200 setup failed!"))
        case .sendBinary:
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Flash erasing failed!", comment: "Flash erasing failed!"))
        case .setBaudrate9600:
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Binary Uploading failed!", comment: "Binary Uploading failed!"))
        case .showResult:
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Baudrate 9600 setup maybe fail! Please reset the chip!", comment: "Baudrate 9600 setup maybe fail! Please reset the chip!"))
            self.uploadSucceeded()
            return
        default:
            return
        }
        self.uploadFailed()
    }
    /// Send failure notification to the user of the uploader.
    @objc func uploadFailed() {
        NotificationCenter.default.post(name: NSNotification.Name.uploadingFailed, object: self)
    }
    /// Send success notification to the user of the uploader.
    func uploadSucceeded() {
        self.progressValue = 100.0
        self.progressInfo = NSLocalizedString("Upload succeeded!", comment: "Upload succeeded!")
        NotificationCenter.default.post(name: NSNotification.Name.uploadingSucceeded, object: self)
    }
    
    // MARK: - UI Related
    /// Inform the view controller to update the progress bar.
    func postProgressUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name.updatedProgress, object: self)
    }
    
    // MARK: - ORSSerialPortDelegate
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.uploadFailed()
        _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Serial Port Disconnected, Uploading Failed", comment: "Serial Port Disconnected, Uploading Failed"))
        self.uploadConfigReady = false
    }
    
    /// Response to serialPort Error
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        let alertMessage = NSLocalizedString("Serial Port", comment: "Serial Port") + "\(serialPort) " + NSLocalizedString("encountered an error: ", comment: "encountered an error: ") + "\(error)"
        _ = InfoAndAlert.shared.showAlertWindow(with: alertMessage)
        self.serialPort = nil
        self.uploadConfigReady = false
    }
    
    // MARK: - Send Command
    /// Send command to board
    func sendCommandToBoard(command: String, responsePrefix: String?, responseSuffix: String?, bufferSize: UInt, userInfo: Any?) {
        let responseDescriptor = ORSSerialPacketDescriptor(prefixString: responsePrefix, suffixString: responseSuffix, maximumPacketLength: bufferSize, userInfo: userInfo)
        self.sendCommandToBoard(command: command, responseDescriptor: responseDescriptor, userInfo: userInfo)
    }
    /// Send command to board
    func sendCommandToBoard(command: String, responseDescriptor: ORSSerialPacketDescriptor, userInfo: Any?) {
        let commandData = command.data(using: .ascii)!
        let request = ORSSerialRequest(dataToSend: commandData,
                                       userInfo: userInfo,
                                       timeoutInterval: timeoutDuration,
                                       responseDescriptor: responseDescriptor)
        self.serialPort?.send(request)
    }
    func sendDataToBoardAndGetResponse(data: Data, responsePrefix: String?, responseSuffix: String?, bufferSize: UInt, userInfo: Any?) {
        let responseDescriptor = ORSSerialPacketDescriptor(prefixString: responsePrefix, suffixString: responseSuffix, maximumPacketLength: bufferSize, userInfo: userInfo)
        let request = ORSSerialRequest(dataToSend: data,
                                       userInfo: userInfo,
                                       timeoutInterval: timeoutDuration,
                                       responseDescriptor: responseDescriptor)
        self.serialPort?.send(request)
    }
    
    // MARK: - Send Data
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
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Fail to send", comment: "Fail to send")+" \(aString)")
        }
    }
    
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
                timeoutDuration = Double(self.binaryData.count) / 1000
                self.sendDataToBoardAndGetResponse(data: self.binaryData, responsePrefix: "p1 final index", responseSuffix: "Menu", bufferSize: 120, userInfo: "sendBinary")
//                DispatchQueue.main.async {
//                    [weak self] in
//                    if let uploader = self {
//                        uploader.waitForChip()
//                        myDebug("binary count = \(self?.binaryData.count)\n")
//                        myDebug("Wait")
//                        for _ in 0...uploader.binaryData.count/500 {
//                            print(".", terminator: "")
//                            uploader.waitForChip()
//                        }
//                        uploader.sendData("1")
//                        uploader.waitForChip()
//                        uploader.sendData("1f800702\n")
//                    }
//                }
                self.currentUploadStage = .setBaudrate9600
            default: return
            }
        }
    }
    
    @objc func sendExitSignalToBoard() {
        self.sendData("\n");
        self.sendData("\n");
    }
    
    /// Timeout reaction
    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        myDebug("Serial port timeout!")
        myDebug(request.userInfo as! String)
        self.timeout()
    }
}
