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
    
    func materialCard(index: Int) -> String {
        let percent = boronPercent/100.0
        let C2H4 = 1 - percent
        let C = C2H4 * (1.0 / 3.0)
        let H = C2H4 - C
        let B10 = percent * (19.9 / 80.1)
        let B11 = percent - B10
        let precision = 6
        return """
M\(index) 6000.60c \(C.stringWith(precision: precision)) 1001.60c \(H.stringWith(precision: precision))
   5010.60c \(B10.stringWith(precision: precision)) 5011.60c \(B11.stringWith(precision: precision)) $ Boron(\(boronPercent)%)-Polyethylene
"""
    }
    
}
