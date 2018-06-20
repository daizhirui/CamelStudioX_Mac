//
//  MyDebug.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/29.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

func myDebug( _ content:Any) {
    #if DEBUG
    Swift.print(content)
    #endif
}
