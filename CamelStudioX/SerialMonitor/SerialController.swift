//
//  SerialController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

public enum Ending: String {
    case noEnding = ""
    case rEnding = "\r"
    case nEnding = "\n"
    case rnEnding = "\r\n"
}

class SerialController: NSObject, ORSSerialPortDelegate, NSUserNotificationCenterDelegate {
    
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
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = self
        }
    }
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
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
        NSUserNotificationCenter.default.delegate = self
    }
    
    /**
     The following functions deal with the notification and action of serial port connection and disconnection
    */
    /// Post a notification when serial port is connected
    @objc func serialPortsWereConnected(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
            print("Ports were connected: \(connectedPorts)")
            let userNotificationCenter = NSUserNotificationCenter.default
            for port in connectedPorts {
                let userNote = NSUserNotification()
                userNote.title = NSLocalizedString("Serial Port Connected", comment: "Serial Port Connected")
                userNote.informativeText = NSLocalizedString("Serial Port", comment: "Serial Port")
                userNote.informativeText?.append("\(port.name)")
                userNote.informativeText?.append(NSLocalizedString(" was connected to your Mac.", comment: " was connected to your Mac."))
                userNote.soundName = NSUserNotificationDefaultSoundName
                userNotificationCenter.deliver(userNote)
            }
        }
    }
    /// Post a notification when serial ports is disconnected
    @objc func serialPortsWereDisconnected(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let disconnectedPorts = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
            print("Ports were disconnected: \(disconnectedPorts)")
            let userNotificationCenter = NSUserNotificationCenter.default
            for port in disconnectedPorts {
                let userNote = NSUserNotification()
                userNote.title = NSLocalizedString("Serial Port Disconnected", comment: "Serial Port Disconnected")
                userNote.informativeText = "Serial Port \(port.name) was disconnected from your Mac."
                userNote.soundName = NSUserNotificationDefaultSoundName
                userNotificationCenter.deliver(userNote)
            }
        }
    }
    /// NSUserNotifcationCenterDelegate function
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            center.removeDeliveredNotification(notification)
        }
    }
    /// NSUserNotifcationCenterDelegate function
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
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
        print("\(serialPort.name) is opened")
    }
    /// response to serialPort closed
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        self.switchButton?.title = NSLocalizedString("Open", comment: "Open")
        print("\(serialPort.name) is closed")
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
            _ = showAlertWindow(with: NSLocalizedString("Serial Port Not Selected", comment: "NSAlert Content"))
        }
    }
    /// response to serialPort Error
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        let alertMessage = NSLocalizedString("Serial Port", comment: "Serial Port") + "\(serialPort) " + NSLocalizedString("encountered an error: ", comment: "encountered an error: ") + "\(error)"
        _ = showAlertWindow(with: alertMessage)
        self.switchButton?.title = NSLocalizedString("Open", comment: "Open")
        NotificationCenter.default.post(name: NSNotification.Name.failToOpenPort, object: self)
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
    /// store all the data received
    var receivedDataBuffer: String = "" {
        didSet {
            if self.checkFlag {
                if self.receivedDataBuffer.count <= self.recentReceivedDataSize {
                    self.recentReceivedData = self.receivedDataBuffer
                } else {
                    let endIndex = self.receivedDataBuffer.endIndex
                    let startIndex = self.receivedDataBuffer.index(endIndex, offsetBy: -self.recentReceivedDataSize)
                    self.recentReceivedData = String(self.receivedDataBuffer[startIndex..<endIndex])
                }
            }
        }
    }
    /// store recent received data
    var recentReceivedData: String = "" {
        didSet {
            if self.checkFlag {
                // check now!
                if self.recentReceivedData.hasSuffix(self.nextStageSignal) {
                    self.checkFlag = false
                    // time for next stage!
                    NotificationCenter.default.post(name: NSNotification.Name.timeForNextUploadStage, object: self)
                }
            }
        }
    }
    /// the size of recentReceivedData
    var recentReceivedDataSize = 270
    /// for uploader, the switch of recent data check
    var checkFlag = false
    /// notification trigger for uploader
    var nextStageSignal = "CamelStudio"
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
    var scrollControll: NSScrollView?
    var screen: NSTextView?
    @objc var autoScroll: Bool = true
}
