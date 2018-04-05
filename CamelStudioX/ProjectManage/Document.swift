//
//  Document.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/1.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    override var fileURL: URL? {
        didSet{
            // update project.projectURL,
            // then project.projectName and project.fileWrappers are auto-set
            self.project.projectURL = fileURL
        }
    }
    
    let project: ProjectManager = ProjectManager(of: nil)

    override init() {
        super.init()
        Swift.print("\(self) is created")
    }
    
    deinit {
        Swift.print("\(self) is destroyed")
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! DocumentWindowController
        // connect document to windowController.contentViewController
        if let viewController = windowController.contentViewController as? DocumentViewController {
            viewController.project = self.project
        }
        self.addWindowController(windowController)
    }
    
    /**
     Return fileWrappers to save
    */
    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        // Check the file is showed and update it
        if let viewController = NSApp.mainWindow?.contentViewController as? DocumentViewController {
            if !viewController.isOperatingFile {
                _ = viewController.checkFileModification()
            } else {
                viewController.isOperatingFile = false
            }
        }
        //self.project.updateFileWrappers() update from disk should be done by the user
        if let fileWrappers = self.project.filewrappers {
            /*
            for childfileWrapper in fileWrappers.fileWrappers!.values {
                if childfileWrapper.isRegularFile {
                    Swift.print(childfileWrapper.preferredFilename!)
                    if let data = childfileWrapper.regularFileContents {
                        if let aString = String(data: data, encoding: .utf8) {
                            Swift.print(aString)
                        }
                        Swift.print()
                    }
                }
            }*/
            let cmsContent =
            """
            TECH = \(self.project.chipType.rawValue)
            COMPILER_PATH =
            TARGET = \(self.project.targetName)
            TARGET_ADDRESS = \(self.project.targetAddress)
            DATA_ADDRESS = \(self.project.dataAddress)
            RODATA_ADDRESS = \(self.project.rodataAddress)
            ARCHITECT = standalone
            AUTOLOAD = false
            C_SOURCES = \(self.project.C_SourceFiles.joined(separator: " "))
            A_SOURCES = \(self.project.A_SourceFiles.joined(separator: " "))
            HEADERS = \(self.project.headerFiles.joined(separator: " "))
            //DEBUG =
            CUSTOM_LIBRARY = \(self.project.customLibrary.joined(separator: " "))
            LIBRARY = \(self.project.library.joined(separator: " "))
            """
            // Add cms file
            if let cmsData = cmsContent.data(using: .utf8) {
                self.project.filewrappers?.update(withContents: cmsData, preferredName: "\(self.project.projectName).cms")
            }
            // Add Config.json
            if let cmsxData = self.project.jsonDataOfConfiguration {
                self.project.filewrappers?.update(withContents: cmsxData, preferredName: "Config.json")
            } else {
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
            }
            return fileWrappers
        } else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }

    /**
     Load data from fileWrapper provided
     self.fileURL is ready now.
    */
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        //debugPrint(self.fileURL ?? "")
        var failureItem = [String]()    // To record items that we fail to load
        if typeName == "com.camel.cmsproj" {
            if let fileWrappers = fileWrapper.fileWrappers {
                if let configRawData = fileWrappers["Config.json"]?.regularFileContents {
                    if let configDict = (try? JSONSerialization.jsonObject(with: configRawData, options: [.allowFragments])) as? Dictionary<String, AnyObject> {
                        // Start to load configuration
                        // Load project.chipType
                        if let chipType = configDict["ChipType"] as? String {
                            switch chipType {
                            case "M3": self.project.chipType = ChipType.M3
                            case "M2": self.project.chipType = ChipType.M2
                            default: _ = showAlertWindow(with: NSLocalizedString("Wrong Chip Type!", comment: "Wrong Chip Type!"))
                            }
                        } else {
                            failureItem.append(NSLocalizedString("Chip Type", comment: "ChipType"))
                        }
                        // Load project.targetName
                        if let targetName = configDict["TargetName"] as? String {
                            self.project.targetName = targetName
                        } else {
                            failureItem.append(NSLocalizedString("Target Name", comment: "Target Name"))
                        }
                        // Load project.targetAddress
                        if let targetAddress = configDict["TargetAddress"] as? String {
                            self.project.targetAddress = targetAddress
                        } else {
                            failureItem.append(NSLocalizedString("Target Address", comment: "Target Address"))
                        }
                        // Load project.dataAddress
                        if let dataAddress = configDict["DataAddress"] as? String {
                            self.project.dataAddress = dataAddress
                        } else {
                            failureItem.append(NSLocalizedString("Data Address", comment: "Data Address"))
                        }
                        // Load project.rodataAddress
                        if let rodataAddress = configDict["RodataAddress"] as? String {
                            self.project.rodataAddress = "\(rodataAddress)"
                        }
                        // Load project.C_SourceFiles
                        if let cSourceFile = configDict["C_Source"] as? [String] {
                            self.project.C_SourceFiles = cSourceFile
                        } else {
                            failureItem.append(NSLocalizedString("C Source Files", comment: "C Source Files"))
                        }
                        // Load project.A_SourceFiles
                        if let aSourceFile = configDict["A_Source"] as? [String] {
                            self.project.A_SourceFiles = aSourceFile
                        } else {
                            failureItem.append(NSLocalizedString("A Source Files", comment: "A Source Files"))
                        }
                        // Load project.headerFiles
                        if let headerFiles = configDict["Headers"] as? [String] {
                            self.project.headerFiles = headerFiles
                        } else {
                            failureItem.append(NSLocalizedString("Header Files", comment: "Header Files"))
                        }
                        // Load project.customLibrary
                        if let customLibrary = configDict["CustomLibrary"] as? [String] {
                            self.project.customLibrary = customLibrary
                        } else {
                            failureItem.append(NSLocalizedString("Custom Library", comment: "Custom Library"))
                        }
                        // Load project.library
                        if let library = configDict["Library"] as? [String] {
                            self.project.library = library
                        } else {
                            failureItem.append(NSLocalizedString("Official Library", comment: "Official Library"))
                        }
                        if failureItem.count > 0 {
                            _ = showAlertWindow(with: NSLocalizedString("The following settings fail to import:\n", comment: "The following settings fail to import:\n")+failureItem.joined(separator: ", "))
                        }
                        return
                    } else {
                        // Fail to load Config file
                        self.project.targetName = self.project.projectName
                        self.project.updateSourceFiles()
                        _ = showAlertWindow(with: NSLocalizedString("Fail to load configuration!", comment: "Fail to load configuration!"))
                        return
                    }
                }
            }
        } else if typeName == "com.camel.cms" {
            /**
             Get the value from cms file
            */
            func getValue(item: String) -> String? {
                if item.contains("=") {
                    // get the value
                    let rawValue = item.components(separatedBy: "=")[1]
                    let finalValue = rawValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if finalValue.count > 0 {
                        return finalValue
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            }
            /**
             Deal with the failure of loading cms file
            */
            func failToLoadCmsFile() {
                self.project.targetName = self.project.projectName
                self.project.updateSourceFiles()
                _ = showAlertWindow(with: NSLocalizedString("Fail to load configuration!", comment: "Fail to load configuration!"))
            }
            // get the cmsFileName
            if let cmsFileName = self.fileURL?.lastPathComponent {
                // update self.fileURL
                if let url = self.fileURL?.deletingLastPathComponent() {
                    self.fileURL = url  // self.project.projectURL, projectName and project.fileWrappers are auto-set
                    if let cmsData = self.project.filewrappers?.fileWrappers?[cmsFileName]?.regularFileContents {
                        if let cmsString = String(data: cmsData, encoding: String.Encoding.utf8) {
                            let items = cmsString.components(separatedBy: .newlines)
                            for item in items {
                                // Load project.chipType
                                if item.hasPrefix("TECH") {
                                    if item.contains("M2") {
                                        self.project.chipType = ChipType.M2
                                    } else if item.contains("M3") {
                                        self.project.chipType = ChipType.M3
                                    } else {
                                        _ = showAlertWindow(with: NSLocalizedString("Wrong Chip Type!", comment: "Wrong Chip Type!"))
                                    }
                                } else if item.hasPrefix("TARGET") && !item.hasPrefix("TARGET_ADDRESS"){
                                    // Load project.targetName
                                    if let value = getValue(item: item) {
                                        self.project.targetName = value
                                    } else {
                                        failureItem.append(NSLocalizedString("Target Name", comment: "Target Name"))
                                    }
                                } else if item.hasPrefix("TARGET_ADDRESS") {
                                    // Load project.targetAddress
                                    if let value = getValue(item: item) {
                                        self.project.targetAddress = value
                                    } else {
                                        failureItem.append(NSLocalizedString("Target Address", comment: "Target Address"))
                                    }
                                } else if item.hasPrefix("DATA_ADDRESS") {
                                    // Load project.dataAddress
                                    if let value = getValue(item: item) {
                                        self.project.dataAddress = value
                                    } else {
                                        failureItem.append(NSLocalizedString("Data Address", comment: "Data Address"))
                                    }
                                } else if item.hasPrefix("RODATA_ADDRESS") {
                                    // Load project.rodataAddress
                                    if let value = getValue(item: item) {
                                        self.project.rodataAddress = value
                                    }
                                } else if item.hasPrefix("C_SOURCES") {
                                    // Load project.C_SourceFiles
                                    if let value = getValue(item: item) {
                                        self.project.C_SourceFiles = value.components(separatedBy: CharacterSet.whitespaces)
                                    }
                                } else if item.hasPrefix("A_SOURCES") {
                                    // Load project.A_SourceFiles
                                    if let value = getValue(item: item) {
                                        self.project.A_SourceFiles = value.components(separatedBy: CharacterSet.whitespaces)
                                    }
                                } else if item.hasPrefix("HEADERS") {
                                    // Load project.headerFiles
                                    if let value = getValue(item: item) {
                                        self.project.headerFiles = value.components(separatedBy: CharacterSet.whitespaces)
                                    }
                                } else if item.hasPrefix("CUSTOM_LIBRARY") {
                                    // Load project.customLibrary
                                    if let value = getValue(item: item) {
                                        self.project.customLibrary = value.components(separatedBy: CharacterSet.whitespaces)
                                    }
                                } else if item.hasPrefix("LIBRARY") {
                                    // Load project.library
                                    if let value = getValue(item: item) {
                                        self.project.library = value.components(separatedBy: CharacterSet.whitespaces)
                                    }
                                }
                                _ = showAlertWindow(with: NSLocalizedString(".cms is an old file type! Some settings may missing and that may result in crash!", comment: ".cms is an old file type! Some settings may missing and that may result in crash!"))
                                if failureItem.count > 0 {
                                    _ = showAlertWindow(with: NSLocalizedString("The following settings fail to import:\n", comment: "The following settings fail to import:\n")+failureItem.joined(separator: ", "))
                                }
                            }
                        } else {
                            // Fail to load cms file
                            failToLoadCmsFile()
                            return
                        }
                    } else {
                        // Fail to load cms file
                        failToLoadCmsFile()
                        return
                    }
                } else {
                    // Fail to load cms file
                    failToLoadCmsFile()
                    return
                }
            } else {
                // Fail to load cms file
                failToLoadCmsFile()
                return
            }
            return
        }
        // No machted typeName
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

}

