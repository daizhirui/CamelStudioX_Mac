//
//  NSxtensions.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/6/1.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

extension NSTextView {
    func turnOffAllSmartOrAutoFunctionExceptLinkDetection() {
        self.isAutomaticDashSubstitutionEnabled = false;
        self.isAutomaticTextReplacementEnabled = false;
        self.isAutomaticQuoteSubstitutionEnabled = false
        self.isAutomaticSpellingCorrectionEnabled = false
        
        if #available(OSX 10.12.2, *) {
            self.isAutomaticTextCompletionEnabled = false
        } else {
            // Fallback on earlier versions
        }
        self.isAutomaticLinkDetectionEnabled = true
        self.isContinuousSpellCheckingEnabled = false
        self.isGrammarCheckingEnabled = false
    }
}
