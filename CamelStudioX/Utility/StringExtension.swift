//
//  StringExtension.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/5/31.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

extension String {
    func toDouble(isHex: Bool) -> Double? {
        if isHex {
            return Double.init("0X"+self)
        } else {
            return Double.init(self)
        }
    }
    func toHex() -> String {
        var hexString = ""
        var lastValue: UInt32 = 0
        for unicodeValue in self.unicodeScalars {
            let value = unicodeValue.value
            if value >= 0 && value <= 255 {
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
    
    func range(of subString: String) -> NSRange? {
        
        var index = 0
        guard let sign = subString.first else { return nil }
        // Loop through parent string looing for the first character of the substring
        for char in self {
            if sign == char {
                
                let startOfFoundCharacter = self.index(self.startIndex, offsetBy: index)
                let lengthOfFoundCharacter: String.Index
                if subString.count > self.count - index {
                    return nil
                } else {
                    lengthOfFoundCharacter = self.index(startOfFoundCharacter, offsetBy: subString.count)
                }
                
                // Grab the substring from the parent string and compare it against substring
                // Essentially, looking for the needle in a haystack
                if self[startOfFoundCharacter..<lengthOfFoundCharacter] == subString {
                    return NSMakeRange(index, subString.count)
                }
            }
            index += 1
        }
        
        return nil
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
