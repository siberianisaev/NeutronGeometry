//
//  Scintillator.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 28/05/2019.
//  Copyright © 2019 Flerov Laboratory. All rights reserved.
//

import Foundation

class Scintillator {
    
    var size: Float = 0
    var thikness: Float = 0
    var positionZ: Float = 0
    
    init(size: Float, thikness: Float, positionZ: Float) {
        self.size = size
        self.thikness = thikness
        self.positionZ = positionZ
    }
    
}
