//===--- Options.swift ----------------------------------------------------===//
//
//Copyright (c) 2016 Daniel Leping (dileping)
//
//This file is part of Markdown.
//
//Swift Express is free software: you can redistribute it and/or modify
//it under the terms of the GNU Lesser General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//Swift Express is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU Lesser General Public License for more details.
//
//You should have received a copy of the GNU Lesser General Public License
//along with Swift Express.  If not, see <http://www.gnu.org/licenses/>.
//
//===----------------------------------------------------------------------===//

import Foundation
//import CDiscount

public struct Options : OptionSet {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let None                     = Options(rawValue: 0)
    public static let NoLinks                  = Options(rawValue: UInt32(MKD_NOLINKS))
    public static let NoImage                  = Options(rawValue: UInt32(MKD_NOIMAGE))
    public static let NoPants                  = Options(rawValue: UInt32(MKD_NOPANTS))
    public static let NoHTML                   = Options(rawValue: UInt32(MKD_NOHTML))
    public static let Strict                   = Options(rawValue: UInt32(MKD_STRICT))
    public static let TagText                  = Options(rawValue: UInt32(MKD_TAGTEXT))
    
    public static let NoExt                    = Options(rawValue: UInt32(MKD_NOEXT))
    public static let CData                    = Options(rawValue: UInt32(MKD_CDATA))
    public static let NoSuperscript            = Options(rawValue: UInt32(MKD_NOSUPERSCRIPT))
    public static let NoRelaxed                = Options(rawValue: UInt32(MKD_NORELAXED))
    public static let NoTables                 = Options(rawValue: UInt32(MKD_NOTABLES))
    public static let NoStrikethrough          = Options(rawValue: UInt32(MKD_NOSTRIKETHROUGH))
    public static let TableOfContents          = Options(rawValue: UInt32(MKD_TOC))
    public static let Compat1                  = Options(rawValue: UInt32(MKD_1_COMPAT))
    public static let Autolink                 = Options(rawValue: UInt32(MKD_AUTOLINK))
    public static let Safelink                 = Options(rawValue: UInt32(MKD_SAFELINK))
    public static let NoHeader                 = Options(rawValue: UInt32(MKD_NOHEADER))
    public static let TabStop                  = Options(rawValue: UInt32(MKD_TABSTOP))
    public static let NoDivQuote               = Options(rawValue: UInt32(MKD_NODIVQUOTE))
    public static let NoAlphaList              = Options(rawValue: UInt32(MKD_NOALPHALIST))
    public static let NoDefList                = Options(rawValue: UInt32(MKD_NODLIST))
    public static let ExtraFootnote            = Options(rawValue: UInt32(MKD_EXTRA_FOOTNOTE))
    
    //    Not in this version
    //    public static let NoStyle                = Options(rawValue: UInt32(MKD_NOSTYLE))
    //    public static let NoDiscountDefList      = Options(rawValue: UInt32(MKD_NODLDISCOUNT))
    //    public static let ExtraDefList           = Options(rawValue: UInt32(MKD_DLEXTRA))
    //    public static let FencedCode             = Options(rawValue: UInt32(MKD_FENCEDCODE))
    //    public static let IdAnchor               = Options(rawValue: UInt32(MKD_IDANCHOR))
    //    public static let GithubTags             = Options(rawValue: UInt32(MKD_GITHUBTAGS))
    //    public static let UrlEncodedAnchor       = Options(rawValue: UInt32(MKD_URLENCODEDANCHOR))
    
    public static let Embed:Options            = [.NoLinks, .NoImage, .TagText]
}
