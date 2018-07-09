//
//  StringExtension.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/5/31.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

extension String {
    /// Convert a string to double
    func toDouble(isHex: Bool) -> Double? {
        if isHex {
            return Double.init("0X"+self)
        } else {
            return Double.init(self)
        }
    }
    /// Convert an ascii string to hex expression, and insert a newline where '\r' or '\n' appears
    func toHex() -> String {
        var hexString = ""
        var lastValue: UInt32 = 0
        // get unicode values
        for unicodeValue in self.unicodeScalars {
            let value = unicodeValue.value
            if value >= 0 && value <= 255 { // ascii value
                if value == 10 { //"\n" or "\r\n"
                    hexString.append(String(format:"%02X ",value))
                    hexString.append("\n")
                } else if lastValue == 13 { // "\r"
                    hexString.append("\n")
                    hexString.append(String(format:"%02X ",value))
                } else {
                    hexString.append(String(format:"%02X ",value))
                }
                lastValue = value
            }
        }
        return hexString
    }

    /// Get all strings by a regular expression
    func getStringByRegularExpression(pattern: String, options: NSRegularExpression.Options) -> [String] {
        var result = [String]()
        
        guard let reglx = try? NSRegularExpression(pattern: pattern, options: options) else {
            return result
        }
        
        let matches = reglx.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        
        let nsstring = self as NSString
        for match in matches {
            result.append(nsstring.substring(with: match.range))
        }
        
        return result
    }
}

extension Array where Element == NSAttributedString {
    /// Connect members of a NSAttributedString Array into a new NSAttributedString
    func join(separator: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let separatorString = NSAttributedString(string: separator)
        for (index, attributedString) in self.enumerated() {
            if index > 0 {
                result.append(separatorString)
            }
            result.append(attributedString)
        }
        return result
    }
}
