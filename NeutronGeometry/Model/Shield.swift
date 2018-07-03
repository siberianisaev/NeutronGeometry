//
//  Shield.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 03/07/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Foundation

class Shield {
    
    var thiknessX: Float = 0
    var thiknessY: Float = 0
    var boronPercent: Float = 0
    
    init(thiknessX: Float, thiknessY: Float, boronPercent: Float) {
        self.thiknessX = thiknessX
        self.thiknessY = thiknessY
        self.boronPercent = boronPercent
    }
    
}
