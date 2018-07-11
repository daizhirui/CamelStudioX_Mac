//
//  MakefileGenerator.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/6/25.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Foundation

class MakefileGenerator {
    static func generate(compiler: Compiler) -> String {
        
        if compiler.project.library.contains("soft_fp") {   // float point library!
            compiler.gcc_Option.append("-msoft-float ")
        }
        if compiler.project.library.contains("stdio")
            || compiler.project.library.contains("stdio_fp")
            || compiler.project.library.contains("stdlib")
            || compiler.project.library.contains("stdlib_fp") {
            compiler.gcc_Option.append("-fno-builtin ")
        }
        
        var fileContent =
        """
        TARGET_NAME = \(compiler.project.targetName)
        OBJ_DIR = release
        BIN_DIR = release
        LIB_DIR = lib
        TARGET_ADDRESS = \(compiler.project.targetAddress)
        DATA_ADDRESS = \(compiler.project.dataAddress)
        RODATA_ADDRESS = \(compiler.project.rodataAddress)
        
        COMPILER_PATH = \(compiler.compilerDirectoryPath)
        GCC = $(COMPILER_PATH)\(compiler.gcc_MIPS_Compiler)
        GCC_OPTION = \(compiler.gcc_Option)
        AS = $(COMPILER_PATH)\(compiler.as_MIPS_Compiler)
        AS_OPTION = \(compiler.as_Option)
        LD = $(COMPILER_PATH)\(compiler.ld_MIPS_Compiler)
        LD_OPTION = \(compiler.ld_Option) -Ttext $(TARGET_ADDRESS) -Tdata $(DATA_ADDRESS) $(if $(RODATA_ADDRESS),--section-start .rodata=$(RODATA_ADDRESS),)
        OBJDUMP = $(COMPILER_PATH)\(compiler.objdump_MIPS_Compiler)
        AR = $(COMPILER_PATH)\(compiler.ar_MIPS_Compiler)
        AR_OPTION = \(compiler.ar_Option)
        CONVERTER = $(COMPILER_PATH)../convert
        CONVERTER_OPTION = -m
        
        C_SOURCE = \(compiler.project.C_SourceFiles.joined(separator: " "))
        C_OBJECT = $(C_SOURCE:.c=.o)
        A_SOURCE = \(compiler.project.A_SourceFiles.joined(separator: " "))
        A_OBJECT = $(A_SOURCE:.s=.o)
        ENTRY_FILE = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/lib/M2/entry.o
        
        CHIP_HEADER = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/include/M2
        STD_HEADER = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/include/std
        CORE_HEADER = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/include/core
        HEADER_FLAGS = -I $(CHIP_HEADER) -I $(STD_HEADER) -I $(CORE_HEADER) -I ./
        
        CHIP_LIBRARY = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/lib/M2
        STD_LIBRARY = \(Bundle.main.bundlePath)/Contents/Resources/Developer/OfficialLibrary/lib/std
        LIBRARY_FLAGS = -L $(STD_LIBRARY) -L $(CHIP_LIBRARY)
        """
        
        for item in compiler.project.library {
            fileContent.append(" -l\(item)")
        }
        
        if compiler.project.customLibrary.count > 0 {
            fileContent.append(" -L ../lib")
            for item in compiler.project.customLibrary {
                fileContent.append(" -l\(item)")
            }
        }
        
        fileContent.append(" -lisr\n")
        
        fileContent.append(
        """
        all: $(TARGET_NAME)
        
        $(TARGET_NAME):$(C_OBJECT) $(A_OBJECT)
        \tmkdir -p $(OBJ_DIR);mkdir -p $(BIN_DIR);mkdir -p $(LIB_DIR);
        \tcd $(OBJ_DIR);$(LD) $(LD_OPTION) -o ../$(BIN_DIR)/$(TARGET_NAME) $(ENTRY_FILE) $^ $(LIBRARY_FLAGS);
        \t$(CONVERTER) $(CONVERTER_OPTION) $(BIN_DIR)/$(TARGET_NAME)
        
        lib:$(C_OBJECT) $(A_OBJECT)
        \tcd $(OBJ_DIR);$(AR) $(AR_OPTION) ../$(LIB_DIR)/lib$(TARGET_NAME).a $^
        
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
        )
        
        return fileContent
    }
}
