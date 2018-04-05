//
//  Terminal.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/3/19.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
func runCommand(run command: String, with arguments: [String]) -> (String, String) {
    // Create a Process instance
    let task = Process()
    // Set the process parameters
    task.launchPath = command
    task.arguments = arguments
    // Create a Pip and make the task
    // put all the output there
    let stdPipe = Pipe()
    let errorPipe = Pipe()
    task.standardOutput = stdPipe
    task.standardError = errorPipe
    // Launch the task
    task.launch()
    // Get the data
    let stdData = stdPipe.fileHandleForReading.readDataToEndOfFile()
    let stdOutput = String(data: stdData, encoding: String.Encoding.utf8)
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: String.Encoding.utf8)
    return (stdOutput ?? "", errorOutput ?? "")
}

/// Compute the prefix sum of `seq`.
internal func scan<
    S : Sequence, U
    >(_ seq: S, _ initial: U, _ combine: (U, S.Iterator.Element) -> U) -> [U] {
    var result: [U] = []
    result.reserveCapacity(seq.underestimatedCount)
    var runningResult = initial
    for element in seq {
        runningResult = combine(runningResult, element)
        result.append(runningResult)
    }
    return result
}

public func withArrayOfCStrings<R>(
    _ args: [String], _ body: ([UnsafeMutablePointer<CChar>?]) -> R
    ) -> R {
    let argsCounts = Array(args.map { $0.utf8.count + 1 })
    let argsOffsets = [ 0 ] + scan(argsCounts, 0, +)
    let argsBufferSize = argsOffsets.last!
    
    var argsBuffer: [UInt8] = []
    argsBuffer.reserveCapacity(argsBufferSize)
    for arg in args {
        argsBuffer.append(contentsOf: arg.utf8)
        argsBuffer.append(0)
    }
    
    return argsBuffer.withUnsafeMutableBufferPointer {
        (argsBuffer) in
        let ptr = UnsafeMutableRawPointer(argsBuffer.baseAddress!).bindMemory(
            to: CChar.self, capacity: argsBuffer.count)
        var cStrings: [UnsafeMutablePointer<CChar>?] = argsOffsets.map { ptr + $0 }
        cStrings[cStrings.count - 1] = nil
        return body(cStrings)
    }
}

/// Spawns a child process.
///
/// - Returns: A pair containing the return value of `posix_spawn` and the pid of the spawned process.
func spawn(path: String, arguments: [String]) -> (retval: Int32, pid: pid_t) {
    // Add the program's path to the arguments
    let argsIncludingPath = [path] + arguments
    
    return withArrayOfCStrings(argsIncludingPath) { argv in
        var pid: pid_t = 0
        let retval = posix_spawn(&pid, path, nil, nil, argv, nil)
        return (retval, pid)
    }
}

