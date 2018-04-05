//
//  ProjectModel.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/2.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

public enum ChipType: String {
    case M2 = "M2"
    case M3 = "M3"
}

public class AvailabelOfficialLibrary {
    static let M2Library = ["AFE", "IO", "irq", "LCD", "SPI", "str", "string", "extend_str", "TC0", "TC1", "TC2", "TC4", "time", "UART0_Lin", "UART1_Lin", "UART0", "UART0", "WDT"]
    static let M3Library = ["AFE", "EV", "EXTIN", "UART1", "TC0", "MCUIO", "str"]
}

class ProjectManager: NSObject {
    
    var author: String = ""
    /**
     Automatically set targetName if SetTargetNameAutomatically in Preference.plist is true
     and targetName is empty.
    */
    var projectName: String = "" {
        didSet {
            if self.targetName == "" {
                if let path = Bundle.main.path(forResource: "Preference", ofType: "plist") {
                    if let setTargetNameAutomatically = NSMutableDictionary(contentsOfFile: path)?.object(forKey: "SetTargetNameAutomatically") as? Bool {
                        if setTargetNameAutomatically {
                                self.targetName = self.projectName
                        }
                    }
                }
            }
            
        }
    }
    
    /**
     The directory path of the project
     When set, set fileWrappers and projectName
    */
    var projectURL: URL? {
        didSet {
            if let url = self.projectURL {
                self.filewrappers = try? FileWrapper(url: url, options: .immediate)
                // use filename to store the url
                self.filewrappers?.filename = self.projectURL?.relativePath
                self.projectName = url.deletingPathExtension().lastPathComponent
            }
        }
    }
    
    /**
     Store project files
    */
    var filewrappers: FileWrapper? = FileWrapper(directoryWithFileWrappers: [:])
    
    func saveFileWrappers() {
        if let url = self.projectURL {
            do {
                try self.filewrappers?.write(to: url, options: .withNameUpdating, originalContentsURL: url)
            } catch {
                print(error)
            }
        }
    }
    
    func updateFileWrappers() {
        if let url = self.projectURL {
            _ = try? self.filewrappers?.read(from: url, options: [.immediate])
        }
    }
    
    // project configuration
    /***
     Not used yet:
     var architect = "standalone"
     var autoload = false
     var debug = false
    */
    var chipType = ChipType.M2
    var targetName: String = ""
    var targetAddress = "10000000"
    var dataAddress = "01000010"
    var rodataAddress = ""
    var C_SourceFiles = [String]()
    var A_SourceFiles = [String]()
    var headerFiles = [String]()
    var customLibrary = [String](){
        // remove ""
        didSet {
            for index in ( 0..<self.customLibrary.count ) {
                if self.customLibrary[index] == "" {
                    self.customLibrary.remove(at: index)
                }
            }
        }
    }
    var library = [String](){
        // remove ""
        didSet {
            for index in ( 0..<self.library.count ) {
                if self.library[index] == "" {
                    self.library.remove(at: index)
                }
            }
        }
    }
    /**
     Json format data of project configuration file
    */
    var jsonDataOfConfiguration: Data? {
        get {
            var dataDictionary = Dictionary<String, Any>()
            dataDictionary["ChipType"] = self.chipType.rawValue
            if self.targetName.count > 0 {
                dataDictionary["TargetName"] = targetName
                dataDictionary["TargetAddress"] = self.targetAddress
                dataDictionary["DataAddress"] = self.dataAddress
                dataDictionary["RodataAddress"] = self.rodataAddress
                self.updateSourceFiles()
                dataDictionary["C_Source"] = self.C_SourceFiles
                dataDictionary["A_Source"] = self.A_SourceFiles
                dataDictionary["Headers"] = self.headerFiles
                dataDictionary["CustomLibrary"] = self.customLibrary
                dataDictionary["Library"] = self.library
                let data = try? JSONSerialization.data(withJSONObject: dataDictionary, options: [.prettyPrinted])
                return data
            } else {
                _ = showAlertWindow(with: NSLocalizedString("Target Name is empty!", comment: "Target Name is empty!"))
                return nil
            }
        }
    }
    
    /**
     Require the directory url of the project.
     fileWrappers and projectName will be setup automatically.
    */
    init (of url: URL?) {
        self.projectURL = url
    }
    
    /**
     Update C_SourceFiles and A_SourceFiles
    */
    func updateSourceFiles() {
        self.C_SourceFiles = [String]()
        self.A_SourceFiles = [String]()
        if let fileWrappers = self.filewrappers?.fileWrappers {
            for (name, fileWrapper) in fileWrappers {
                if name.hasPrefix(".") {
                    continue    // Ignore hidden files
                } else {
                    if fileWrapper.isDirectory {
                        continue    // Ignore directories
                    } else {
                        if name.uppercased().hasSuffix(".C") {
                            self.C_SourceFiles.append(name)
                            self.C_SourceFiles = Array(Set(self.C_SourceFiles))
                        } else if name.uppercased().hasSuffix(".S") {
                            self.A_SourceFiles.append(name)
                            self.A_SourceFiles = Array(Set(self.A_SourceFiles))
                        }
                    }
                }
            }
        }
    }
}

extension FileWrapper {
    
    var fileLanguage: String {
        get {
            if !self.isDirectory {
                // get the fileName
                if let fileName = self.preferredFilename {
                    if !fileName.hasPrefix(".") {
                        if fileName.contains(".") {
                            let parts = fileName.components(separatedBy: ".")
                            let name = parts[0].lowercased()
                            let type = parts[1].lowercased()
                            if name == "makefile" {
                                return "makefile"
                            }
                            switch type {
                            case "cms": return "makefile"
                            case "json": return "json"
                            case "s": return "mipsasm"
                            case "make": return "makefile"
                            case "cmake": return "cmake"
                            default: return "cpp"
                            }
                        } else {
                            if fileName.lowercased() == "makefile" {
                                return "makefile"
                            }
                        }
                    }
                }
            }
            return "cpp"
        }
    }
    /**
     Check if there is a fileWrapper with the same name before add a new one.
     If finded, the original fileWrapper will be removed before a new one is added.
     
     - Author: Zhirui Dai
     
     - parameters:
        - fileWrapper: The new fileWrapper to add.
    */
    func update(_ fileWrapper: FileWrapper) {
        if self.isDirectory {
            if let keys = self.fileWrappers?.keys {
                if let name = fileWrapper.preferredFilename {
                    // try to remove a fileWrapper with the same name
                    if keys.contains(name) {
                        if let fileWrapperToMove = self.fileWrappers?[name] {
                            self.removeFileWrapper(fileWrapperToMove)
                        }
                    }
                }
            }
            // add the new fileWrapper
            self.addFileWrapper(fileWrapper)
        }
    }
    /**
     Check if there is a fileWrapper with the same name before add a new one.
     If finded, the original fileWrapper will be removed before a new one is added.
     
     - Author: Zhirui Dai
     
     - parameters:
        - withContents: The new fileWrapper's content
        - preferredName: The new fileWrapper's preferredName
     */
    func update(withContents: Data, preferredName: String) {
        let fileWrapper = FileWrapper(regularFileWithContents: withContents)
        fileWrapper.preferredFilename = preferredName
        self.update(fileWrapper)
    }
    
    var regularFileString: String? {
        get {
            if let regularFileContent = self.regularFileContents {
                return String(data: regularFileContent, encoding: .utf8)
            } else {
                return nil
            }
        }
    }
}

extension FileWrapper: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        var copy: FileWrapper!
        if self.isRegularFile {
            copy = FileWrapper(regularFileWithContents: self.regularFileContents!)
            copy.preferredFilename = self.preferredFilename
            return copy as Any
        } else if self.isSymbolicLink {
            copy = FileWrapper(symbolicLinkWithDestinationURL: self.symbolicLinkDestinationURL!)
            copy.preferredFilename = self.preferredFilename
            return copy as Any
        } else {
            copy = FileWrapper(directoryWithFileWrappers: [:])
            copy.preferredFilename = self.preferredFilename
            if let childFileWrappers = self.fileWrappers {
                for (_, childFileWrapper) in childFileWrappers {
                    copy.addFileWrapper(childFileWrapper.copy(with: nil) as! FileWrapper)
                }
                return copy as Any
            } else {
                return copy as Any
            }
        }
    }
    
    
}
