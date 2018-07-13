//
//  Compiler.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/2.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

struct CompilerMessages {
    var success = true
    var normal = [NSAttributedString]()
    var warnings = [NSAttributedString]()
    var errors = [NSAttributedString]()
}

enum CompilerMessagesType {
    case error, warning, normal
}

class Compiler: NSObject {

    var project: ProjectManager!
    
    var compilerDirectoryPath = Bundle.main.bundlePath + "/Contents/Resources/Developer/Toolchains/bin/"
    var gcc_MIPS_Compiler = "mips-netbsd-elf-gcc"
    var gcc_Option = "-EL -DPRT_UART -march=mips1 -std=c99 -c -G0 -O2 -msoft-float -Wall -Wextra "
    var as_MIPS_Compiler = "mips-netbsd-elf-as"
    var as_Option = "-EL"
    var ld_MIPS_Compiler = "mips-netbsd-elf-ld"
    var ld_Option = "-EL -eentry -s -N"
    var objdump_MIPS_Compiler = "mips-netbsd-elf-objdump"
    var ar_MIPS_Compiler = "mips-netbsd-elf-ar"
    var ar_Option = "rcs"
    var errorList = [String]()
    
    init(forProject project: ProjectManager) {
        self.project = project
    }
    
    /*
     Try to generate a makefile and store it in the project directory. true will be returned when success.
     If it fails, an alert window will be showed and false will be returned.
     */
    func generateMakefile() -> Bool {
        if self.project.projectURL != nil {
            // save project file at first
            //self.project.saveFileWrappers()
            NSDocumentController.shared.currentDocument?.save(self)
            self.project.updateSourceFiles()
            // start to generate Makefile
            if self.project.targetName.count > 0 {
                
                let makefileContent = MakefileGenerator.generate(compiler: self)
                
                // store the Makefile
                if let data = makefileContent.data(using: String.Encoding.utf8) {
                    self.project.filewrappers?.update(withContents: data, preferredName: "Makefile")
                    NSDocumentController.shared.saveAllDocuments(self)
                }
                return true
            } else {
                _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("Target Name is empty!", comment: "Target Name is empty!"))
                return false
            }
        } else {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("No project to build!", comment: "No project to build!"))
            return false
        }
    }
    
    /**
     Build a binary for the project and return output
    */
    func buildBinary() -> CompilerMessages {
        var stdOutput: String = ""
        var errorOutput: String = ""
        let originalWorkingDirectoryPath = FileManager.default.currentDirectoryPath
        if let projectPath = self.project.projectURL?.relativePath {
            FileManager.default.changeCurrentDirectoryPath(projectPath)
            myDebug(FileManager.default.currentDirectoryPath)
            (stdOutput, errorOutput) = runCommand(run: "/usr/bin/make", with: [])
        } else {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("No project to build!", comment: "No project to build!"))
        }
        // update project.fileWrappers
        self.project.updateFileWrappers()
        FileManager.default.changeCurrentDirectoryPath(originalWorkingDirectoryPath)
        return Compiler.processMessages(stdOutput: stdOutput, stdErrorOutput: errorOutput)
    }
    
    /**
     Build a library for the project and return output
    */
    func buildLibrary() -> CompilerMessages {
        var stdOutput: String = ""
        var errorOutput: String = ""
        let originalWorkingDirectoryPath = FileManager.default.currentDirectoryPath
        if let projectPath = self.project.projectURL?.relativePath {
            FileManager.default.changeCurrentDirectoryPath(projectPath)
            (stdOutput, errorOutput) = runCommand(run: "/usr/bin/make", with: ["lib"])
        } else {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("No project to build!", comment: "No project to build!"))
        }
        // update project.fileWrappers
        self.project.updateFileWrappers()
        FileManager.default.changeCurrentDirectoryPath(originalWorkingDirectoryPath)
        return Compiler.processMessages(stdOutput: stdOutput, stdErrorOutput: errorOutput)
    }
    
    /**
     Clean the project
    */
    func cleanProject() -> (String, String) {
        var stdOutput: String = ""
        var errorOutput: String = ""
        let originalWorkingDirectoryPath = FileManager.default.currentDirectoryPath
        if let projectPath = self.project.projectURL?.relativePath {
            FileManager.default.changeCurrentDirectoryPath(projectPath)
            (stdOutput, errorOutput) = runCommand(run: "/usr/bin/make", with: ["clean"])
        } else {
            _ = InfoAndAlert.shared.showAlertWindow(with: NSLocalizedString("No project to clean!", comment: "No project to clean!"))
        }
        // update project.fileWrappers
        self.project.updateFileWrappers()
        FileManager.default.changeCurrentDirectoryPath(originalWorkingDirectoryPath)
        return (stdOutput, errorOutput)
    }
    
    static private func processMessages(stdOutput: String, stdErrorOutput: String) -> CompilerMessages {
        var compilerMessage = CompilerMessages()
        if stdOutput.count > 0 {
            for message in stdOutput.components(separatedBy: .newlines) {
                let attributedMessage = NSAttributedString(string: message)
                compilerMessage.normal.append(attributedMessage)
            }
        }
        if stdErrorOutput.count > 0 {
            var compilerMessageType: CompilerMessagesType = .normal
            var attributedMessage = NSMutableAttributedString(string: "")
            for item in stdErrorOutput.components(separatedBy: .newlines) {
                if item.contains("-msoft-float") {  // Ignore the warning of using soft float
                    continue
                }
                var newItem = item
                if let range: Range<String.Index> = newItem.range(of: "mips") {             // remove the path of the compiler
                    newItem.removeSubrange(newItem.startIndex..<range.lowerBound)
                }
                func addMessage() {
                    switch compilerMessageType {
                        case .error:
                            compilerMessage.errors.append(attributedMessage)
                        case .warning:
                            compilerMessage.warnings.append(attributedMessage)
                        case .normal:
                            // some messages from stderr, but these messages appear before "warning" or "error"
                            compilerMessage.warnings.append(attributedMessage)
                    }
                }
                if let range: NSRange = newItem.lowercased().range(of: "warning")?.toNSRange(string: newItem) {
                    // Detect a new start of a warning
                    addMessage()
                    attributedMessage = NSMutableAttributedString(string: newItem)
                    attributedMessage.addAttributes([.foregroundColor : NSColor.orange as Any], range: range)
                    compilerMessageType = .warning
                } else if let range: NSRange = newItem.lowercased().range(of: "error")?.toNSRange(string: newItem) {
                    // Detect a new start of an error
                    addMessage()
                    attributedMessage = NSMutableAttributedString(string: newItem)
                    attributedMessage.addAttributes([.foregroundColor : NSColor.red as Any], range: range)
                    compilerMessageType = .error
                    compilerMessage.success = false
                } else {
                    let messageDetail = NSAttributedString(string: "\n"+newItem)
                    attributedMessage.append(messageDetail)
                }
            }
        }
        return compilerMessage
    }
}
