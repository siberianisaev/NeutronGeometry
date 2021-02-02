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
    
    func materialCard(index: Int) -> String {
        // Cs2LiLa(Br6)90%(Cl6)10%:Ce --- Cs 2 Li6 0.95 Li7 0.05 La 1 Br 4.8 Cl 1.2 Ce 1
        return "M\(index) 55133.50c 2 3006.42c 0.95 3007.42c 0.05 57139.26y 1 35079.55c 4.8 17000.35c 1.2 58140.30y 1 $ CLLBC:Ce"
    }
    
}
