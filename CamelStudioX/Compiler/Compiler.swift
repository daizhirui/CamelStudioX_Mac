//
//  Compiler.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/2.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa

class Compiler: NSObject {

    var project: ProjectManager!
    
    var compilerDirectoryPath = Bundle.main.bundlePath + "/Contents/Resources/Developer/Toolchains/bin/"
    var gcc_MIPS_Compiler = "mips-netbsd-elf-gcc"
    var gcc_Option = "-EL -DPRT_UART -march=mips1 -std=c99 -c"
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
            self.project.saveFileWrappers()
            self.project.updateSourceFiles()
            // start to generate Makefile
            if self.project.targetName.count > 0 {
                let makefileContent =
                """
                TARGET_NAME = \(self.project.targetName)
                OBJ_DIR = release
                BIN_DIR = release
                LIB_DIR = lib
                TARGET_ADDRESS = \(project.targetAddress)
                DATA_ADDRESS = \(project.dataAddress)
                RODATA_ADDRESS = \(project.rodataAddress)
                
                COMPILER_PATH = \(self.compilerDirectoryPath)
                GCC = $(COMPILER_PATH)\(self.gcc_MIPS_Compiler)
                GCC_OPTION = \(gcc_Option)
                AS = $(COMPILER_PATH)\(self.as_MIPS_Compiler)
                AS_OPTION = \(as_Option)
                LD = $(COMPILER_PATH)\(self.ld_MIPS_Compiler)
                LD_OPTION = \(self.ld_Option) -Ttext $(TARGET_ADDRESS) -Tdata $(DATA_ADDRESS) $(if $(RODATA_ADDRESS),--section-start .rodata=$(RODATA_ADDRESS),)
                OBJDUMP = $(COMPILER_PATH)\(self.objdump_MIPS_Compiler)
                AR = $(COMPILER_PATH)\(self.ar_MIPS_Compiler)
                AR_OPTION = \(ar_Option)
                CONVERTER = $(COMPILER_PATH)../convert
                CONVERTER_OPTION = -m
                
                C_SOURCE = \(project.C_SourceFiles.joined(separator: " "))
                C_OBJECT = $(C_SOURCE:.c=.o)
                A_SOURCE = \(project.A_SourceFiles.joined(separator: " "))
                A_OBJECT = $(A_SOURCE:.s=.o)
                ENTRY_FILE = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/lib/M2/entry.o
                
                CHIP_HEADER = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/include/M2
                STD_HEADER = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/include/std
                CORE_HEADER = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/include/core
                HEADER_FLAGS = -I $(CHIP_HEADER) -I $(STD_HEADER) -I $(CORE_HEADER) -I ./
                
                CHIP_LIBRARY = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/lib/M2
                STD_LIBRARY = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/lib/std
                LIBRARY_FLAGS = -L $(STD_LIBRARY) -l string -L $(CHIP_LIBRARY) -l interrupt -l str \(project.library.count > 0 ? "-l  "+project.library.joined(separator: " -l ") : "") \(project.customLibrary.count > 0 ? ("-L ../lib -l  "+project.customLibrary.joined(separator: " -l ")) : "")
                
                all: $(TARGET_NAME)
                
                $(TARGET_NAME):$(C_OBJECT) $(A_OBJECT)
                \tmkdir -p $(OBJ_DIR);mkdir -p $(BIN_DIR);mkdir -p $(LIB_DIR);
                \tcd $(OBJ_DIR);$(LD) $(LD_OPTION) -o ../$(BIN_DIR)/$(TARGET_NAME) $(ENTRY_FILE) $^ $(LIBRARY_FLAGS);
                \t$(CONVERTER) $(CONVERTER_OPTION) $(BIN_DIR)/$(TARGET_NAME)
                \techo "Success"
                
                lib:$(C_OBJECT) $(A_OBJECT)
                \tcd $(OBJ_DIR);$(AR) $(AR_OPTION) ../$(LIB_DIR)/lib$(TARGET_NAME).a $^
                \techo "Success"
                
                clean:
                \trm -f $(OBJ_DIR)/*
                \trm -f $(BIN_DIR)/*
                \trm -f $(LIB_DIR)/*
                
                .c.o:
                \tmkdir -p $(OBJ_DIR);mkdir -p $(BIN_DIR);mkdir -p $(LIB_DIR);
                \t$(GCC) $(GCC_OPTION) $(HEADER_FLAGS) -o $(OBJ_DIR)/$@ $<
                .s.o:
                \tmkdir -p $(OBJ_DIR);mkdir -p $(BIN_DIR);mkdir -p $(LIB_DIR);
                \t$(AS) $(AS_OPTION) -o $(OBJ_DIR)/$@ $<
                """
                // store the Makefile
                if let data = makefileContent.data(using: String.Encoding.utf8) {
                    self.project.filewrappers?.update(withContents: data, preferredName: "Makefile")
                    NSDocumentController.shared.saveAllDocuments(self)
                }
                return true
            } else {
                _ = showAlertWindow(with: NSLocalizedString("Target Name is empty!", comment: "Target Name is empty!"))
                return false
            }
        } else {
            _ = showAlertWindow(with: NSLocalizedString("No project to build!", comment: "No project to build!"))
            return false
        }
    }
    
    /**
     Build a binary for the project and return output
    */
    func buildBinary() -> (String, String) {
        var stdOutput: String = ""
        var errorOutput: String = ""
        let originalWorkingDirectoryPath = FileManager.default.currentDirectoryPath
        if let projectPath = self.project.projectURL?.relativePath {
            FileManager.default.changeCurrentDirectoryPath(projectPath)
            (stdOutput, errorOutput) = runCommand(run: "/usr/bin/make", with: [])
        } else {
            _ = showAlertWindow(with: NSLocalizedString("No project to build!", comment: "No project to build!"))
        }
        // update project.fileWrappers
        self.project.updateFileWrappers()
        FileManager.default.changeCurrentDirectoryPath(originalWorkingDirectoryPath)
        return (stdOutput, errorOutput)
    }
    
    /**
     Build a library for the project and return output
    */
    func buildLibrary() -> (String, String) {
        var stdOutput: String = ""
        var errorOutput: String = ""
        let originalWorkingDirectoryPath = FileManager.default.currentDirectoryPath
        if let projectPath = self.project.projectURL?.relativePath {
            FileManager.default.changeCurrentDirectoryPath(projectPath)
            (stdOutput, errorOutput) = runCommand(run: "/usr/bin/make", with: ["lib"])
        } else {
            _ = showAlertWindow(with: NSLocalizedString("No project to build!", comment: "No project to build!"))
        }
        // update project.fileWrappers
        self.project.updateFileWrappers()
        FileManager.default.changeCurrentDirectoryPath(originalWorkingDirectoryPath)
        return (stdOutput, errorOutput)
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
            _ = showAlertWindow(with: NSLocalizedString("No project to clean!", comment: "No project to clean!"))
        }
        // update project.fileWrappers
        self.project.updateFileWrappers()
        FileManager.default.changeCurrentDirectoryPath(originalWorkingDirectoryPath)
        return (stdOutput, errorOutput)
    }
}
