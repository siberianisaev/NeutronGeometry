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
        return """
M\(index) 55133.60c -0.1819 3006.50c -0.0864 3007.55c -0.0045
       35079.55c -0.4364 17000.60c -0.109 57139. -0.0909 58140. -0.0909
"""
    }
    
    /*
     In cm^3.
     */
    func volume() -> Float {
        return pow(size, 2) * thikness
    }
    
    func tallyCoefficient() -> Float {
        let v = volume()
        return Counter.tallyCoefficient(presure: 7, volume: v)
    }
    
}
