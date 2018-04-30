//
//  SerialBoardController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/30.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

class SerialBoardController: NSObject, ORSSerialPortDelegate {
    
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
            }
        }
    }
    /**
     Initalize the super class and add notifications of "Serial ports were disconnected" to the notification center.
     */
    override init() {
        super.init()
    }
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
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
        let responseDescriptor = ORSSerialPacketDescriptor(prefixString: nil, suffixString: responseSuffix, maximumPacketLength: bufferSize, userInfo: userInfo)
        self.sendCommandToBoard(command: command, responseDescriptor: responseDescriptor, userInfo: userInfo)
    }
    func sendCommandToBoard(command: String, responseDescriptor: ORSSerialPacketDescriptor, userInfo: Any?) {
        let commandData = command.data(using: .ascii)!
        let request = ORSSerialRequest(dataToSend: commandData,
                                       userInfo: userInfo,
                                       timeoutInterval: 1.0,
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
    var receivedResponse: String = ""
    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        if let response = String(data: responseData, encoding: .utf8) {
            self.receivedResponse = response
            myDebug(response)
        }
    }
    
    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        myDebug(request.userInfo as! String)
    }

}
