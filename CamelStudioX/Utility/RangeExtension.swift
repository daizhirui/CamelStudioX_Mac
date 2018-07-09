//
//  RangeExtension.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/6/25.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Foundation

extension Range where Bound == String.Index {
    /// Convert Range<String.Index> to NSRange
    func toNSRange(string: String) -> NSRange {
        let location = string.distance(from: string.startIndex, to: self.lowerBound)
        let length = string.distance(from: self.lowerBound, to: self.upperBound)
        return NSMakeRange(location, length)
    }
}
