//
//  SerialController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import ORSSerial

public enum Ending: String {
    case noEnding = ""
    case rEnding = "\r"
    case nEnding = "\n"
    case rnEnding = "\r\n"
}

class SerialController: NSObject, ORSSerialPortDelegate {
    
    /// bool value to control enableness of a switch button
    @objc var switchIsEnabled: Bool {
        get {
            return self.serialPort != nil
        }
    }
    /// use the default serial port manager
    @objc let serialPortManager = ORSSerialPortManager.shared()
    /**
     an ORSSerialPort instance to store the current used serial port
     When the serial port selected is changed, the didSetter will release the old one
     and connect the delegate to the new one automatically
     */
    @objc var serialPort: ORSSerialPort? {
        willSet{
            serialPort?.close()
            serialPort?.delegate = nil
        }
        didSet {
            serialPort?.delegate = self
            SerialController.recentSerialPort = self.serialPort // store recent serial port
            if let portName = serialPort?.name {
                UserDefaults.standard.set(portName, forKey: "recentSerialPort")
            }
        }
    }
    /// To remember the serial port choosed recently.
    static var recentSerialPort: ORSSerialPort?
    /// Available baudrates
    @objc let availableBaudrates = [300, 1200, 2400, 4800, 9600, 14400, 19200, 28800, 38400, 57600, 115200, 230400]
    /**
     Initalize the super class and add notifications of "Serial ports were connected" and "Serial ports were
     disconnected" to the notification center.
     */
    override init() {
        super.init()
        // setup the notification center
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereChanged(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereChanged(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
    }
    
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
    
    // ORSSerialPortDelegate
    /**
     Response to serialPort removed
     - Remove the serialPort (set to nil)
     - Update switchTitle to "Open"
    */
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.switchButton?.title = NSLocalizedString("Open", comment: "Open")
    }
    /// response to serialPort opened
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        self.switchButton?.title = NSLocalizedString("Close", comment: "Close")
        myDebug("\(serialPort.name) is opened")
    }
    /// response to serialPort closed
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        self.switchButton?.title = NSLocalizedString("Open", comment: "Open")
        myDebug("\(serialPort.name) is closed")
    }
    /**
     Open or close the serial port
    */
    func openOrClosePort() {
        if let port = self.serialPort {
            if (port.isOpen) {
                port.close()
            } else {
                port.open()
            }
        } else {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Serial Port Not Selected", comment: "NSAlert Content"))
        }
    }
    /// response to serialPort Error
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        let alertMessage = NSLocalizedString("Serial Port", comment: "Serial Port") + "\(serialPort) " + NSLocalizedString("encountered an error: ", comment: "encountered an error: ") + "\(error)"
        _ = InfoAndAlert.shared.showAlertWindow(with: alertMessage)
        self.switchButton?.title = NSLocalizedString("Open", comment: "Open")
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
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Fail to send", comment: "Fail to send")+" \(aString)")
        }
    }
    /// store all the data received
    var receivedDataBuffer: String = ""
    
    /**
     Receive and store data
    */
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let aString = String(data: data, encoding: String.Encoding.utf8) {
            self.receivedDataBuffer.append(aString) // store the data
            if let screen = self.screen {
                let attributedFeedback = NSAttributedString(string: aString, attributes: [NSAttributedStringKey.foregroundColor : NSColor.black])
                screen.textStorage?.append(attributedFeedback)
                if autoScroll {
                    screen.scrollToEndOfDocument(self)
                }
            }
        }
    }
    
    // ********************** For Serial Monitor UI *****************************
    var switchButton: NSButton?
    //var scrollControll: NSScrollView?
    var screen: NSTextView?
    @objc var autoScroll: Bool = true
}
